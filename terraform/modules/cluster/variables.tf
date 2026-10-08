variable "name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.37"
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_security_group_id" {
  type = string
}

variable "admin_cidrs" {
  description = "IP ranges allowed to reach the public Kubernetes API"
  type        = list(string)
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}