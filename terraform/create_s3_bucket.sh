#!/bin/bash

# Configurações padrão
AWS_REGION="us-east-1"
BACKEND_FILE="backend.tf"
BUCKET_NAME=""

# Função para exibir ajuda
function show_help() {
    echo "Uso: $0 --bucket-name <nome-do-bucket> [--region <região>]"
    exit 1
}

# Parse dos argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        --bucket-name)
            BUCKET_NAME="$2"
            shift 2
            ;;
        --region)
            AWS_REGION="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo " Opção inválida: $1"
            show_help
            ;;
    esac
done

# Verifica se o nome do bucket foi fornecido
if [[ -z "$BUCKET_NAME" ]]; then
    echo " Você deve fornecer um nome para o bucket usando --bucket-name"
    show_help
fi

# Verifica se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo " AWS CLI não encontrado! Instale antes de executar o script."
    exit 1
fi

# Verifica se o bucket já existe
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo " O bucket '$BUCKET_NAME' já existe!"
else
    # Se a região for diferente de "us-east-1", adicionamos o LocationConstraint
    if [[ "$AWS_REGION" == "us-east-1" ]]; then
        aws s3api create-bucket --bucket "$BUCKET_NAME"
    else
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi

    # Habilitando versionamento
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled

    echo " Bucket '$BUCKET_NAME' criado com sucesso na região '$AWS_REGION'!"
fi

# Criando o arquivo backend.tf para configuração do Terraform
cat <<EOF > $BACKEND_FILE
terraform {
  backend "s3" {
    bucket  = "$BUCKET_NAME"
    key     = "terraform.tfstate"
    region  = "$AWS_REGION"
    encrypt = true
  }
}
EOF

echo " Arquivo '$BACKEND_FILE' criado para configuração do backend do Terraform!"