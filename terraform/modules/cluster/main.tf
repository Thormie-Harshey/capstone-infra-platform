resource "aws_eks_cluster" "main" {
  name     = var.name
  version  = var.kubernetes_version
  role_arn = var.cluster_role_arn

  # Whoever creates the cluster becomes its administrator
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = true            # nodes reach the API privately
    endpoint_public_access  = true            # your laptop reaches it publicly...
    public_access_cidrs     = var.admin_cidrs # only from your IP
  }

  # Never slip into the expensive extended support
  upgrade_policy {
    support_type = "STANDARD"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.node_instance_type]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  # Replace servers one at a time during upgrades
  update_config {
    max_unavailable = 1
  }
}

# The disk tool, so the database can get its own storage
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on   = [aws_eks_node_group.main]
}