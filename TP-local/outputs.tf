output "nginx_container_id" { //doit afficher l’identifiant (id) du conteneur nginx 
  description = "ID of the nginx docker container"
  value       = docker_container.nginx.id
}
