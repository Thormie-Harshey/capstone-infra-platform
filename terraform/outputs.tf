output "cluster_name" {
  value = module.cluster.cluster_name
}

output "configure_kubectl" {
  description = "Run this to connect kubectl to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.cluster.cluster_name}"
}