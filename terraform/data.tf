## 🔍 Data Sources para Recursos Existentes

# 1. Buscar a VPC
data "aws_vpc" "existing" {
  id = "vpc-0ab964651fa276a19" # Substitua pelo seu ID real da VPC
}

# 2. Buscar as Subnets Públicas
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# 3. Buscar o Cluster ECS
data "aws_ecs_cluster" "existing" {
  cluster_name = "codepipeline-fargate-cluster"
}


data "aws_ecr_repository" "codepipeline_repo" {
  name = "codepipeline-repo"
}