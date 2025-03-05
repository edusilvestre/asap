# Output formatado para exibir o IP e porta
output "nginx_access" {
  description = "Acesse a aplicação via:"
  value       = "http://${aws_instance.app_server.public_ip}:8080"
}
