variable "vpc_id" {
  description = "VPC ID (used for awsvpc network mode context)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for Fargate tasks"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "ECR repository URL from ecr module"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN from alb module"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS task security group from security module"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory (MiB)"
  type        = number
  default     = 512
}