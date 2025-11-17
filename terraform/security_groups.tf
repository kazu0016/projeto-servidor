resource "aws_security_group" "ecs_sg" {
  name        = "ecs-nginx-sg"
  description = "Security group for ECS nginx service"
  vpc_id      = "vpc-0ab964651fa276a19"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "ecs-nginx-sg"
  }
}
