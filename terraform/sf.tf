## 🛡️ Security Groups (Defesa Principal)

# 1. Security Group para o Application Load Balancer (ALB)
# Permite acesso HTTP (80) da Internet
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.fargate_vpc.id 
  description = "Permite trafego HTTP (80) de qualquer lugar para o ALB."

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

# 2. Security Group para as Tarefas Fargate 
# Permite acesso SOMENTE do ALB
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  vpc_id      = aws_vpc.fargate_vpc.id
  description = "Permite trafego SOMENTE do Security Group do ALB."

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    # Acesso permitido apenas pelo SG do ALB
    security_groups = [aws_security_group.alb_sg.id] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  tags = { Name = "ECS-Tasks-SG" }
}