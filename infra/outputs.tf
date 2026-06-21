## Networking


output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for ALB)"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (for ECS)"
  value       = module.networking.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.networking.internet_gateway_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.networking.nat_gateway_id
}

## ECR

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL (for docker push and ECS task definition)"
  value       = module.ecr.repository_url
}

## ACM

output "acm_certificate_arn" {
  description = "Validated ACM certificate ARN (for ALB HTTPS listener)"
  value       = module.acm.certificate_arn
}

output "app_domain_name" {
  description = "Public app hostname"
  value       = module.acm.domain_name
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (for DNS records)"
  value       = module.acm.route53_zone_id
}

## ALB

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

## ECS

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = module.ecs.task_definition_arn
}

output "ecs_log_group_name" {
  description = "CloudWatch log group for ECS tasks"
  value       = module.ecs.log_group_name
}