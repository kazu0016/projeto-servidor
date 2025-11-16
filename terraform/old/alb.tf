## 🌐 Application Load Balancer (ALB)

# 1. Application Load Balancer
resource "aws_lb" "nginx_alb" {
  name               = "nginx-app-alb"
  internal           = false
  load_balancer_type = "application"
  # Referencia as Subnets Públicas (definidas em vpc.tf)
  subnets            = aws_subnet.public[*].id 
  # Referencia o Security Group do ALB (definido em security_group.tf)
  security_groups    = [aws_security_group.alb_sg.id]
  tags = { Name = "Nginx-ALB" }
}

# 2. Target Group (Para onde o tráfego é roteado)
resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.fargate_vpc.id
  target_type = "ip" # Deve ser 'ip' para ECS Fargate

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
  }
}

# 3. Listener (Ouvinte - Roteia a porta 80 para o Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# Output do DNS do ALB
output "alb_dns_name" {
  description = "DNS Name para acessar o NGINX via ALB"
  value       = aws_lb.nginx_alb.dns_name
}