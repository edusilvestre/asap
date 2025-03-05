terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  #Versionamento State
  backend "s3" {
    bucket  = "terraform-state-asap-eduardo" # Nome do bucket S3 (crie no AWS antes)
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true # Habilita criptografia
  }
}

#onde o recurso está sendo criado
provider "aws" {
  region = "us-east-1"
}

# Criando um Security Group para permitir tráfego na porta desejada
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow traffic on specific port"

  # Regra para permitir entrada (ingress)
  ingress {
    from_port   = 8080 # Altere para a porta que deseja expor
    to_port     = 8080 # Altere para a porta que deseja expor
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso de qualquer IP (modifique para mais segurança)
  }

  # Permitir acesso SSH (para debug)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra para permitir saída (egress) para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criando a instância EC2 e associando ao Security Group
resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  key_name      = "eduardo-silvestre" #ssh-key-name  

  # Associando ao Security Group criado
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Script de inicialização da instância para instalar e configurar o NGINX
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx

              # Docker
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update -y
              sudo apt-get install -y docker-ce

              sudo usermod -aG docker ubuntu

              # Kind
              curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
              chmod +x ./kind
              sudo mv ./kind /usr/local/bin/kind

              # kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              sudo mv kubectl /usr/local/bin/

              # cluster Kind
              kind create cluster
              
              # Modificando todas as ocorrências da porta 80 para 8080
              sudo sed -i 's/listen 80 default_server;/listen 8080 default_server;/g' /etc/nginx/sites-available/default
              sudo sed -i 's/listen \\[::\\]:80 default_server;/listen \\[::\\]:8080 default_server;/g' /etc/nginx/sites-available/default  #analisar se a mudança funcionou

              # Reiniciar o Nginx para aplicar mudanças
              sudo systemctl restart nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "terraform-ec2-nginx"
  }
}
