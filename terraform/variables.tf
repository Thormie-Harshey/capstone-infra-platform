variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "capstone"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "admin_cidrs" {
  description = "Your public IP as x.x.x.x/32, allowed to reach the Kubernetes API"
  type        = list(string)
}