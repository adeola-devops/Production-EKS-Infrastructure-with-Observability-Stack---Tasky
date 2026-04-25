output "security_group_ssh_id" {
    value = aws_security_group.security_group_ssh.id
}

output "security_group_http_id" {
    value = aws_security_group.security_group_http.id
}

output "security_group_MongoDB_id" {
    value = aws_security_group.security_group_MongoDB.id
}

output "security_group_mongoDB-exporter_id" {
  value = aws_security_group.security_group_mongoDB-exporter.id
}

output "security_group_monitoring_id" {
  value = aws_security_group.security_group_monitoring.id
}
