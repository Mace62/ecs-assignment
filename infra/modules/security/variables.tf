variable "vpc_id" {
  description = "VPC to create security groups in"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}