# ---------- Cluster role (worn by EKS itself) ----------
data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------- Node role (worn by the worker servers) ----------
data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",            # join the cluster
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",                 # give pods VPC addresses
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",   # pull AWS system images
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # create disks for the database
  ])
  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# ---------- Security group for the Kubernetes API ----------
resource "aws_security_group" "cluster" {
  name        = "${var.name}-cluster-sg"
  description = "Extra rules for the EKS control plane"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name}-cluster-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "api_from_vpc" {
  security_group_id = aws_security_group.cluster.id
  description       = "Kubernetes API from inside the VPC only"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.cluster.id
  description       = "Allow outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}