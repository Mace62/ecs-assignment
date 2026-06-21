## ALB Security Group
resource "aws_security_group" "allow-web-inbound-all-egress" {
  name        = "allow-web-inbound-all-egress"
  description = "Allows HTTP and HTTPS inbound traffic from the internet and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow-web-inbound-all-egress.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.allow-web-inbound-all-egress.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb-all" {
  security_group_id = aws_security_group.allow-web-inbound-all-egress.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

## ECS Security Group
resource "aws_security_group" "allow-ecs-inbound-from-alb" {
  name        = "allow-ecs-inbound-from-alb"
  description = "Allows inbound traffic from the ALB"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ecs-from-alb" {
  security_group_id = aws_security_group.allow-ecs-inbound-from-alb.id

  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.allow-web-inbound-all-egress.id
}

resource "aws_vpc_security_group_egress_rule" "ecs-all" {
  security_group_id = aws_security_group.allow-ecs-inbound-from-alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
