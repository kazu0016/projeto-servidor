resource "aws_ecr_repository" "nginx_repo" {
  # O NOME AQUI DEVE CORRESPONDER AO SEU REPOSITÓRIO EXISTENTE
  name = "codepipeline-repo" 
  
  # A mutabilidade é tipicamente mantida para implantações de CI/CD
  image_tag_mutability = "MUTABLE" 

  tags = {
    Name = "Nginx-Codepipeline-Repo"
  }
}