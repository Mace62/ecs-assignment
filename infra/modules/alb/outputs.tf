output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name (for Route53 alias later)"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID (for Route53 alias)"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target group for ECS service"
  value       = aws_lb_target_group.main.arn
}