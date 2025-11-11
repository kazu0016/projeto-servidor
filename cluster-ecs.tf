## 🚀 ECS Fargate Cluster, Task Definition e Service

# 1. Cluster ECS Fargate
resource "aws_ecs_cluster" "main" {
  name = "nginx-fargate-cluster"
}

# 2. Task Definition (Define o Container e Recursos)
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-fargate-task"
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Depende da aws_iam_role.ecs_task_execution_role (definido em iam.tf)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "nginx-app"
      # Assume que aws_ecr_repository.nginx_repo é definido em ecr.tf
      image     = "${aws_ecr_repository.nginx_repo.repository_url}:latest" 
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80 # A porta do NGINX no container
          hostPort      = 80
        }
      ]
    }
  ])
}

# 3. ECS Fargate Service (Mantém o número de instâncias rodando)
resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-fargate-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2 # Número de réplicas
  
  # Configuração de Deploy (Permite que o serviço use o ALB)
  deployment_controller {
    type = "CODE_DEPLOY" # Diz ao ECS para usar o CodeDeploy
  }

  network_configuration {
    # Referencia as Subnets Privadas (definidas em vpc.tf)
    subnets          = aws_subnet.private[*].id
    # Referencia o Security Group das tarefas (definido em security_group.tf)
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false # Garante que as tarefas fiquem na rede privada
  }

  # Configuração de Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "nginx-app" 
    container_port   = 80
  }
}