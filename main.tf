terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      # ManagedByTerraform = "true"
      Creator            = "bae"
      # Email              = "flos0422@gmail.com"
    }
  }
}

locals {
  default_name = "test-bae"
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    
    name            = "${local.default_name}-vpc"
    cidr            = "10.0.0.0/16"
    azs             = ["ap-northeast-2a", "ap-northeast-2c"]
    public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
    
    enable_nat_gateway = true
    single_nat_gateway = false


    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"
    
    cluster_name    = "${local.default_name}-eks"
    cluster_version = "1.31"
    
    cluster_endpoint_public_access  = true
    enable_cluster_creator_admin_permissions = true
    
    cluster_addons = {
        coredns                = {
            resolve_conflicts = "OVERWRITE"
        }
        kube-proxy             = {}
        vpc-cni                = {
            resolve_conflicts = "OVERWRITE"
        }
    }
    
    vpc_id                   = module.vpc.vpc_id
    subnet_ids               = module.vpc.private_subnets
    control_plane_subnet_ids = module.vpc.private_subnets
    
    eks_managed_node_groups = {
        "${local.default_name}-node" = {
            ami_type       = "AL2023_x86_64_STANDARD"
            instance_types = ["t3.small"]
            
            min_size     = 2
            max_size     = 4
            desired_size = 2

            labels = {
                "private-subnet" = "true"
            }
        }
    }
    
    depends_on = [ module.vpc ]
}

module "ecr" {
    source = "./module/ecr"
    
    ecr_name = "${local.default_name}-ecr"
}