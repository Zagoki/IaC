output "nginx_container_id" {
  description = "ID of the nginx container"
  value       = docker_container.nginx.id
}
