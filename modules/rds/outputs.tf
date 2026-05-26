output "mysql_endpoint" {
  value = aws_db_instance.mysql.address
}

output "mysql_port" {
  value = aws_db_instance.mysql.port
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.address
}

output "postgres_port" {
  value = aws_db_instance.postgres.port
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.carts.name
}

output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}

output "postgres_secret_arn" {
  value = aws_secretsmanager_secret.postgres.arn
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
