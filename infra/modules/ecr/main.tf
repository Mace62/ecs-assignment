resource "aws_ecr_repository" "main" {
  name = "threatmod-ecr"
  force_delete = true

  tags = {
    Name = "threatmod-ecr"
  }
}