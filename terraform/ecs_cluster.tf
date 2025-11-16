## 🏗️ ECS Cluster e Task Definition

# 1. Cluster ECS Fargate
resource "aws_ecs_cluster" "main" {
  name = "nginx-fargate-cluster"
  
  tags = {
    Name = "Nginx-CD-Cluster"
  }
}

# 2. Task Definition 
# (A Task Definition é o blueprint de como o Docker deve rodar)
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-fargate-task"
  cpu                      = "256" 
  memory                   = "512" 
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  # Estes ARNs (IAM Role e ECR Repo) sao definidos em outros arquivos (iam.tf e ecr.tf)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "nginx-app"
      image     = "${aws_ecr_repository.nginx_repo.repository_url}:latest" 
      essential = true
      portMappings = [{ containerPort = 80 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.nginx_logs.name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name = "Nginx-Task-Def"
  }
}

# (Opcional, mas recomendado): Grupo de Logs para o CloudWatch
resource "aws_cloudwatch_log_group" "nginx_logs" {
  name              = "/ecs/nginx-app"
  retention_in_days = 7
}