variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the security group in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC address range allowed to reach the API privately"
  type        = string
}