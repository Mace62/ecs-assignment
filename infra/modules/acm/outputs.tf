output "certificate_arn" {
  description = "Validated ACM certificate ARN (safe to attach to ALB HTTPS listener)"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "domain_name" {
  description = "App hostname covered by the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID (for app alias record to ALB later)"
  value       = data.aws_route53_zone.main.zone_id
}