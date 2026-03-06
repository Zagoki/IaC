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
