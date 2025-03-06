# TESTE TÉCNICO - ASAP

## Resumo
Este repositório possui os arquivos necessários, a identificação de todos eles, os pontos de melhoria e como instalar os recursos.

---
## Índice
1. **O que é cada arquivo**
2. **Pontos de melhoria**
3. **Como executar/instalar**
---

### 1. O que é cada arquivo

- Dentro do repositório possui duas pastas - chart e terraform.
- Na pasta "chart" contém os arquivos Chart.yaml, values.yaml e a sub-pasta "templates" com o arquivo deployment.yaml
- Os arquivos já estavam no .zip do teste e foram corrigidos os erros apresentados usando o "helm lint"

- Na pasta "terraform" contém os arquivos main.tf, outputs.tf, variables.tf e o script create_s3_bucket.sh
- O arquivo main.tf possui as configurações de security group (com portas para nginx e ssh), criação da EC2 e o script de instalação de recursos dentro da EC2
- O arquivo outputs.tf possui apenas a saída com o IP de acesso para o nginx após a criação da máquina EC2
- O arquivo variables.tf possui apenas a variável "padrão" para o nome da EC2
- O script create_s3_bucket.sh foi desenvolvido para criação do bucket e gerar o arquivo backend.tf para configurar o versionamento e state do terraform

### 2. Pontos de melhorias
- O security Group/EC2 está aceitando acesso externo público e utilizando algumas portas padrão (22 e 80/8080), gerando vulnerabilidades dos recursos
- O Nginx não possui nenhuma configuração adicional de segurança, estando suscetível a ataques
- Subir os arquivos do Helm na web para não precisar utilizar o SCP

### 3. Como executar/instalar
- Comece a instalação pelo ./create_s3_bucket.sh utilizando a seguinte sintaxe:  
    - ./create_s3_bucket.sh --bucket-name insira-o-nome-do-bucket
- Após a subida do s3, instalar os arquivos em ./terraform/*
   - terraform init
   - terraform apply
- Assim que a criação dos recursos finalizar, enviar os arquivos do chart/helm para a EC2, exemplo: 
    - scp -i sua-chave.pem chart.zip ubuntu@ip-da-ec2:/home/ubuntu
- Criar o cluster do kind: 
    - sudo kind create cluster --name nome-do-cluster
- Executar a instalação do helm: 
    - helm install /home/ubuntu/. --generate-name
