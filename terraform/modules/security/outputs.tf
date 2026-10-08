# depends_on makes sure the policies are attached before the cluster uses the roles
output "cluster_role_arn" {
  value      = aws_iam_role.cluster.arn
  depends_on = [aws_iam_role_policy_attachment.cluster]
}

output "node_role_arn" {
  value      = aws_iam_role.node.arn
  depends_on = [aws_iam_role_policy_attachment.node]
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}