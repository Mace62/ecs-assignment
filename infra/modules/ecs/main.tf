resource "aws_ecs_cluster" "main" {
  name = "threatmod-ecs-cluster"

  tags = {
    Name = "threatmod-ecs-cluster"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = "threatmod-ecs-log-group"

  tags = {
    Name = "threatmod-ecs-log-group"
  }
}

resource "aws_iam_role" "execution" {
  name = "threatmod-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "threatmod-ecs-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn

  container_definitions = jsonencode([
    {
      name      = "threatmod-ecs-container"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "threatmod-ecs-task-definition"
  }
}

resource "aws_ecs_service" "main" {
  name            = "threatmod-ecs-service"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "threatmod-ecs-container"
    container_port   = var.container_port
  }

  tags = {
    Name = "threatmod-ecs-service"
  }
}