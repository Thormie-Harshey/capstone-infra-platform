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
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",          # join the cluster
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",               # give pods VPC addresses
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", # pull AWS system images
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

# ---------- KMS key for encrypting Kubernetes Secrets ----------
resource "aws_kms_key" "eks_secrets" {
  description             = "Encrypts Kubernetes Secrets in the ${var.name} EKS cluster"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = { Name = "${var.name}-eks-secrets" }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# Let the cluster role use this one key, and nothing else
resource "aws_iam_role_policy" "cluster_kms" {
  name = "${var.name}-eks-secrets-kms"
  role = aws_iam_role.cluster.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Encrypt", "kms:Decrypt", "kms:ListGrants", "kms:DescribeKey"]
      Resource = aws_kms_key.eks_secrets.arn
    }]
  })
}

# ---------- EBS CSI controller role (worn by the disk tool's pods via Pod Identity) ----------
data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
