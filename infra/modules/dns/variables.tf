variable "route53_zone_id" {
  description = "Route53 hosted zone ID for the parent domain"
  type        = string
}

variable "domain_name" {
  description = "App hostname (e.g. tm.sameh-labs.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name from alb module"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB canonical hosted zone ID from alb module"
  type        = string
}