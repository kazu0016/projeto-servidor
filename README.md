🌐 Projeto de Entrega Contínua (CD) no AWS Fargate

📝 Descrição do Projeto

Este projeto demonstra a construção de um pipeline de Entrega Contínua (Continuous Delivery - CD) e a implantação de uma aplicação web containerizada (servidor NGINX) em um ambiente de produção escalável na AWS. Toda a infraestrutura, segurança e configurações de rede foram definidas e provisionadas usando Infraestrutura como Código (IaC).

💻 Linguagens e Tecnologias Utilizadas

Categoria	Tecnologia	Uso Principal no Projeto
Infraestrutura como Código (IaC)	Terraform (HCL)	Definição da VPC, ECS Fargate, ALB, ECR e IAM Roles.
Computação Containerizada	Docker	Criação da imagem de aplicação (NGINX).
Orquestração de Containers	AWS ECS (Fargate)	Plataforma serverless para execução e gerenciamento de containers.
Integração Contínua (CI)	GitHub Actions	Automatiza o build da imagem Docker e o push seguro para o ECR.
Entrega Contínua (CD)	AWS CodePipeline	Orquestração do pipeline que detecta novas imagens no ECR.
Estratégia de Deploy	AWS CodeDeploy	Gerencia a estratégia de implantação Blue/Green no Serviço ECS com Zero Downtime.
Segurança	AWS IAM & OIDC	Autenticação passwordless e segura (OpenID Connect) entre o GitHub e a AWS.

🏛️ Arquitetura de Entrega Contínua (CD)

O pipeline de CD foi desenhado para garantir rapidez, segurança e alta disponibilidade:

Diagrama de Fluxo do Pipeline

O pipeline utiliza uma abordagem de três estágios (Source, Build e Deploy), com o GitHub Actions atuando como a ferramenta de Build/Push e o CodePipeline gerenciando a entrega final.
Estágio	Ferramenta	Objetivo e Processo de Seleção
Source/Build	GitHub Actions	Objetivo: Construir a imagem Docker e enviá-la para o ECR. Seleção: Escolhido pela integração nativa com o repositório e pelo uso do OIDC para autenticação segura (passwordless) na AWS, substituindo a complexidade de servidores de build como o Jenkins.
Source/Trigger	AWS ECR	Objetivo: Iniciar o pipeline. Seleção: É o repositório de imagens nativo e central na AWS. O CodePipeline é configurado para monitorar a tag :latest (ou a tag de commit) e disparar o fluxo.
Deploy	AWS CodeDeploy (ECS)	Objetivo: Atualizar o Serviço ECS com a nova imagem sem inatividade. Seleção: É a ferramenta nativa da AWS para gerenciar implantações Blue/Green em ECS, fornecendo rollback automático e gerenciamento seguro da troca de tráfego via ALB.

Configurações de Rede e Segurança (Terraform)

    VPC: Definida com Subnets Públicas (para o ALB) e Privadas (para as tarefas Fargate).

    VPC Endpoints: Utilizados para permitir que as tarefas Fargate (em Subnets Privadas) acessem o ECR e o S3 de forma segura e privada, eliminando a necessidade e o custo do NAT Gateway.

    Security Groups: Rigorosamente definidos para garantir que o tráfego HTTP/80 só chegue às tarefas através do ALB.

🛠️ Como Instalar e Usar o Projeto

Pré-requisitos

    AWS CLI configurada.

    Terraform instalado.

    Acesso ao seu repositório GitHub.

Configuração de Segurança (OIDC)

A autenticação é feita via OIDC.

    Crie o Provedor OIDC na AWS IAM com o URL https://token.actions.githubusercontent.com.

    Crie o IAM Role (GitHubActionsECRRole) com a política de confiança restrita ao seu repositório:
    JSON

    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:kazu0016/projeto-servidor:*"
    }

    Anexe a política de permissão ECR (AmazonEC2ContainerRegistryPowerUser) ao Role.

Provisionamento da Infraestrutura (Terraform)

Navegue até a pasta que contém seus arquivos .tf e execute:
Bash

# Inicializa o backend e baixa provedores
terraform init

# Visualiza o plano de execução (cerca de 20 a 30 recursos)
terraform plan

# Aplica as mudanças e cria a VPC, ECR, ALB, e Cluster ECS
terraform apply

Build e Push da Imagem (CI - GitHub Actions)

Edite o arquivo index.html ou o Dockerfile. Faça o commit e push para a branch main:
Bash

git add .
git commit -m "Atualiza o servidor web e dispara o pipeline"
git push origin main

O GitHub Actions irá construir a imagem e enviá-la ao ECR.

Entrega Contínua (CD - AWS CodePipeline)

A nova imagem no ECR disparará o pipeline ECS-Nginx-CD-Pipeline. O CodeDeploy executará o deploy Blue/Green no ECS. O DNS do ALB (saída do Terraform) fornecerá o URL final da aplicação.
![Diagrama do Pipeline CI/CD com CodeDeploy](docs/deploy-ecs.drawio.png)
---------------------------------
This is a challenge by Coodesh