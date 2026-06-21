variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "certificate_arn" {
  description = "Validated ACM cert ARN from acm module"
  type        = string
}

variable "container_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/health"
}