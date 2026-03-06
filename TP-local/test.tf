resource "null_resource" "nginx_check" {
  depends_on = [docker_container.nginx]

  # refaire la vérif si le port externe change
  triggers = {
    # triggers requires string values; convert number to string
    port = tostring(var.external_port)
  }

  provisioner "local-exec" {
    # sous Windows on utilise PowerShell, ailleurs curl fonctionne aussi
    command = <<EOT
powershell -NoProfile -Command "(Invoke-WebRequest -Uri http://localhost:${var.external_port} -UseBasicParsing).Content -match 'Welcome'"
EOT
  }
}

# verify that the client container can reach nginx via the docker network
resource "null_resource" "client_check" {
  depends_on = [docker_container.client]

  provisioner "local-exec" {
    command = <<-EOT
powershell -NoProfile -Command "(docker exec ${docker_container.client.name} curl -s http://nginx:80) -match 'Welcome'"
EOT
  }
}

