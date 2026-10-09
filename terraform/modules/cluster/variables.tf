variable "name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.36"
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

variable "secrets_kms_key_arn" {
  description = "KMS key used to encrypt Kubernetes Secrets"
  type        = string
}
variable "ebs_csi_role_arn" {
  description = "IAM role for the EBS CSI controller (Pod Identity)"
  type        = string
}
