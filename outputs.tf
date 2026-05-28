output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = "https://62A9853CD3FD733A7FD17AD641197C9E.gr7.us-east-1.eks.amazonaws.com"
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = module.s3.bucket_name
}
