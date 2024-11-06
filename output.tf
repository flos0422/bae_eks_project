# VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

# EKS Cluster
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# Node Group
output "node_group_arns" {
  value = module.eks.node_security_group_arn
}

# ECR
output "ecr_repository_uri" {
  value = module.ecr.ecr_repository_url
}