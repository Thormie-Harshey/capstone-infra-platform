variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "Address range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}