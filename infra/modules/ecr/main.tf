resource "aws_ecr_repository" "main" {
  name         = "threatmod-ecr"
  force_delete = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = "threatmod-ecr"
  }
}