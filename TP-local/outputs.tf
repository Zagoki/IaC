output "nginx_container_id" {
  # doit afficher l'identifiant (id) du conteneur nginx
  description = "ID of the nginx docker container"
  value       = docker_container.nginx.id
}


output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i deployer-key.pem ec2-user@${aws_instance.web.public_ip}"
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.id
}

output "database_instance_id" {
  description = "ID of the database EC2 instance"
  value       = aws_instance.database.id
}

output "database_instance_public_ip" {
  description = "Public IP of the database EC2 instance"
  value       = aws_instance.database.public_ip
}

output "database_ssh_command" {
  description = "SSH command to connect to the database instance"
  value       = "ssh -i deployer-key.pem ec2-user@${aws_instance.database.public_ip}"
}