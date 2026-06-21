output "alb_security_group_id" {
  description = "Security group for the ALB"
  value       = aws_security_group.allow-web-inbound-all-egress.id
}

output "ecs_security_group_id" {
  description = "Security group for ECS tasks"
  value       = aws_security_group.allow-ecs-inbound-from-alb.id
}