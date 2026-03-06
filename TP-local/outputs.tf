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