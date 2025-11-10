## 🌐 VPC e Subnets

# Variáveis de Configuração
variable "region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { default = ["10.0.10.0/24", "10.0.11.0/24"] }

# 1. Provedor AWS
provider "aws" {
  region = var.region
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

# (Opcional) Data Source para AZs
data "aws_availability_zones" "available" {
  state = "available"
}