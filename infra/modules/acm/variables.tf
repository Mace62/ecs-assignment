variable "domain_name" {
  description = "App hostname for the ACM certificate (e.g. tm.sameh-labs.com)"
  type        = string
  default     = "tm.sameh-labs.com"
}
variable "route53_zone_name" {
  description = "Route53 hosted zone name for DNS validation (trailing dot required)"
  type        = string
  default     = "sameh-labs.com."
}