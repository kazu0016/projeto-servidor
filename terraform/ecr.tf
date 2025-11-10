## 📦 Repositório ECR

resource "aws_ecr_repository" "nginx_repo" {
  name                 = "nginx-fargate-app"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "NGINX-ECR-Repo"
  }
}

# Output para facilitar o push da imagem
output "ecr_repository_url" {
  description = "URL do Repositório ECR"
  value       = aws_ecr_repository.nginx_repo.repository_url
}
