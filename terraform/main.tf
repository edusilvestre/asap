terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

# Provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Gerar chave SSH privada
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Criar a chave pública no AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Salvar a chave privada no diretório local
resource "local_file" "private_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = "${path.module}/terraform-generated-key.pem"
  file_permission = "0400" # Define permissões seguras para a chave
}

# Criar Security Group para a EC2
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow traffic on specific port"

  # Permitir tráfego na porta 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir acesso SSH (22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regras de saída (liberar tudo)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar instância EC2 e associar à chave gerada
resource "aws_instance" "app_server" {
  ami           = "ami-0e1bed4f06a3b463d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name # Usa a chave gerada

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Script de inicialização da instância
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx

              # Docker
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt update -y
              sudo apt install -y docker-ce

              sudo usermod -aG docker ubuntu
              sudo usermod -aG docker $USER
              
              # Kind
              curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
              chmod +x ./kind
              sudo mv ./kind /usr/local/bin/kind

              # kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              sudo mv kubectl /usr/local/bin/

              curl https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz -o helm-v3.9.0-linux-amd64.tar.gz
              tar -zxvf helm-v3.9.0-linux-amd64.tar.gz
              sudo mv linux-amd64/helm /usr/local/bin/helm

              # cluster Kind
              kind create cluster
              
              # Modificando todas as ocorrências da porta 80 para 8080
              sudo sed -i 's/listen 80 default_server;/listen 8080 default_server;/g' /etc/nginx/sites-available/default
              sudo sed -i 's/listen \\[::\\]:80 default_server;/listen \\[::\\]:8080 default_server;/g' /etc/nginx/sites-available/default

              # Reiniciar o Nginx para aplicar mudanças
              sudo systemctl restart nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "terraform-ec2"
  }
}
