## 🌐 Recursos de Rede Simplificados (Public-Only)

# Variáveis
variable "region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }

provider "aws" {
  region = var.region
}

# Data Source para AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. Criação da VPC
resource "aws_vpc" "fargate_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "Fargate-VPC-Public" }
}

# 2. Subnets Públicas (Para ALB e Fargate Tasks)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.fargate_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  # Essencial: Habilita IPs públicos para os recursos (ALB e Fargate)
  map_public_ip_on_launch = true 
  tags = { Name = "Public-Subnet-${count.index}" }
}

# 3. Internet Gateway (IGW) e Roteamento
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