## 🛡️ Security Groups (Assumindo que aws_vpc.fargate_vpc.id está disponível)

# SG 1: Para o Application Load Balancer (ALB) - Público
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.fargate_vpc.id
  description = "Permite HTTP (80) de qualquer lugar para o ALB."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "ALB-SG" }
}

# SG 2: Para as Tarefas Fargate - Restrito
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  vpc_id      = aws_vpc.fargate_vpc.id
  description = "Permite  SOMENTE do Security Group do ALB (Porta 80)."

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    # Permite acesso apenas do ALB
    security_groups = [aws_security_group.alb_sg.id] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Saída para internet (via NAT Gateway)
  }
  tags = { Name = "ECS-Tasks-SG" }
}