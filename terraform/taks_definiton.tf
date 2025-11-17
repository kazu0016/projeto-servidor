resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-fargate-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx-app"
      # Use the data source reference
      image     = "${data.aws_ecr_repository.codepipeline_repo.repository_url}:latest"
      essential = true
      portMappings = [{ containerPort = 80 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = aws_cloudwatch_log_group.nginx_logs.name
          "awslogs-region" = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}