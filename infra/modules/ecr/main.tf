resource "aws_ecr_repository" "main" {
    name = "threatmod-ecr"

    tags = {
        Name = "threatmod-ecr"
    }
}