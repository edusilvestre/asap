provider "aws" {
  region = "us-east-1"
}

# Criando o Bucket S3 para armazenar o Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-asap-eduardo" # Escolha um nome único

  lifecycle {
    prevent_destroy = true # Para evitar que o bucket seja destruído acidentalmente, mude para "true"
  }

  versioning {
    enabled = true # Habilita versionamento para rastrear mudanças no state
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

