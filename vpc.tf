## 🌐 VPC e Subnets (FINAL SEM NAT GATEWAY)

# Variáveis de Configuração
variable "region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { default = ["10.0.10.0/24", "10.0.11.0/24"] }

# 1. Provedor AWS
provider "aws" {
  region = var.region
}

# Data Source para AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. VPC
resource "aws_vpc" "fargate_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "Fargate-VPC" }
}

# 3. Subnets (Para o ALB e Fargate)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.fargate_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "Public-Subnet-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.fargate_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "Private-Subnet-${count.index}" }
}

# 4. Internet Gateway (IGW) e Roteamento Público
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fargate_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.fargate_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "Public-RT" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =======================================================
# 5. VPC Endpoints para ECS e ECR (Substituem o NAT Gateway)
# =======================================================

# Security Group para os VPC Endpoints
resource "aws_security_group" "endpoint_sg" {
  name        = "vpc-endpoint-sg"
  vpc_id      = aws_vpc.fargate_vpc.id
  description = "Permite trafic HTTPS interno para os VPC Endpoints"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Permite acesso de toda a VPC
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5a. VPC Endpoint para o ECS (Interface)
resource "aws_vpc_endpoint" "ecs_endpoint" {
  vpc_id              = aws_vpc.fargate_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

# 5b. VPC Endpoint para o ECR API (Interface)
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id              = aws_vpc.fargate_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

# 5c. VPC Endpoint para o ECR DKR (Interface) - Necessário para pull da imagem
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id              = aws_vpc.fargate_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

# 5d. VPC Endpoint para o S3 (Gateway) - Necessário para Registry/Container Image Layer Access
# O ECS e o ECR usam S3 para armazenar as camadas das imagens.
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id       = aws_vpc.fargate_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.public.id] # Deve ser anexado às tabelas de rota
}