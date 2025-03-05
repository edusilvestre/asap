# TESTE TÉCNICO - ASAP

## Resumo
Este repositório possui os arquivos necessários para subir a infraestrutura do teste

---
## Índice
1. **O que é cada arquivo**
2. **Quais as dificuldades encontradas**
3. **Pontos de melhoria**
4. **Como executar/instalar**
---

### 1. O que é cada arquivo

- Dentro do repositório possui duas pastas - chart e terraform.
- Na pasta "chart" contém os arquivos Chart.yaml, values.yaml e a sub-pasta "templates" com o arquivo deployment.yaml
- Os arquivos já estavam no .zip do teste e foram corrigidos os erros apresentados usando o "helm lint"

- Na pasta "terraform" contém os arquivos main.tf, outputs.tf, variables.tf e a sub-pasta "modules"
- Foi criada uma pasta "modules" para criar o bucket S3 antes de executar os outros arquivos
- O arquivo main.tf possui as configurações de security group (com portas para nginx e ssh), versionamento do state, criação da EC2 e o script de instalação de recursos dentro da EC2
- O arquivo outputs.tf possui apenas a saída com o IP de acesso para o nginx após a criação da máquina EC2
- O arquivo variables.tf possui apenas a variável "padrão" para o nome da EC2

### 2. Quais as dificuldades encontradas
- Na criação do S3 não é possível já configurar o "backend" para versionamento dos states do terraform, foi necessário configurar em duas etapas
- A correção da pasta "chart" foi em cima de identações, que gerou uma certa dificuldade de encontrá-los

### 3. Pontos de melhorias
- O security Group/EC2 está aceitando acesso externo público e utilizando algumas portas padrão (22 e 80/8080), gerando vulnerabilidades dos recursos
- O Nginx não possui nenhuma configuração adicional de segurança, estando suscetível a ataques
- Automatizar a criação do S3 já com o "backend" de versionamento via script, rodando as duas etapas automaticamente sem intervenção manual

### 4. Como executar/instalar
- Comece a instalação pelo ./terraform/modules/backend/s3-state.tf 
  - terraform init / terraform apply
- Após a subida do s3, alterar para a sua chave na linha 59 do arquivo "main.tf" e instalar os arquivos em ./terraform/*
 - terraform init / terraform apply
