# environments/dev/outputs.tf

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "api_server_public_ip" {
  description = "IP público do servidor da API"
  value       = module.api_server.public_ip
}

output "db_endpoint" {
  description = "Endpoint de conexão do banco de dados"
  value       = module.database.db_endpoint
}
