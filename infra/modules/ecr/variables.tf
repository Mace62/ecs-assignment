variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Allow terraform destroy even when images exist"
  type        = bool
  default     = true
}