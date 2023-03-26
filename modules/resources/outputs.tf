output "web_private_server_public_ip" {
  value = aws_instance.web_private_server[*].public_ip
}

output "web_private_server_arn" {
  value = aws_instance.web_private_server[*].arn
}

output "web_public_server_public_ip" {
  value = aws_instance.web_public_server[*].public_ip
}

output "web_public_server_arn" {
  value = aws_instance.web_public_server[*].arn
}