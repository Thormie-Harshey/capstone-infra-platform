terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state in the bootstrap bucket, locked with a lock file in S3
  backend "s3" {
    bucket       = "capstone-tfstate-852396291743"
    key          = "capstone/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  # Inherited by every module, so every resource is tagged the same way
  default_tags {
    tags = {
      Project     = "capstone-infra-platform"
      Owner       = "thormie"
      ManagedBy   = "terraform"
      Environment = "dev"
    }
  }
}

module "networking" {
  source   = "./modules/networking"
  name     = var.project_name
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source   = "./modules/security"
  name     = var.project_name
  vpc_id   = module.networking.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "cluster" {
  source                    = "./modules/cluster"
  name                      = var.project_name
  cluster_role_arn          = module.security.cluster_role_arn
  node_role_arn             = module.security.node_role_arn
  private_subnet_ids        = module.networking.private_subnet_ids
  cluster_security_group_id = module.security.cluster_security_group_id
  admin_cidrs               = var.admin_cidrs
  secrets_kms_key_arn       = module.security.eks_secrets_kms_key_arn
  ebs_csi_role_arn          = module.security.ebs_csi_role_arn
}