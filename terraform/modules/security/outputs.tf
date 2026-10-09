# depends_on makes sure the policies are attached before the cluster uses the roles
output "cluster_role_arn" {
  value      = aws_iam_role.cluster.arn
  depends_on = [aws_iam_role_policy_attachment.cluster, aws_iam_role_policy.cluster_kms]
}

output "eks_secrets_kms_key_arn" {
  value = aws_kms_key.eks_secrets.arn
}

output "node_role_arn" {
  value      = aws_iam_role.node.arn
  depends_on = [aws_iam_role_policy_attachment.node]
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}
output "ebs_csi_role_arn" {
  value      = aws_iam_role.ebs_csi.arn
  depends_on = [aws_iam_role_policy_attachment.ebs_csi]
}
