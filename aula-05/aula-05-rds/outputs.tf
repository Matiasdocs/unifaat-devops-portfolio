output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.api.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/technova-key ec2-user@${aws_instance.api.public_ip}"
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_address" {
  value = aws_db_instance.main.address
}

output "connection_string" {
  value = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -p 5432"
}
