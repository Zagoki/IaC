terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2375"
}

resource "docker_image" "nginx" {
  name = var.docker_image_name
}

resource "docker_network" "app" {
  name = var.network_name
}

resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  depends_on = [docker_network.app]

  # networks = [docker_network.app.id]

  ports {
    external = var.external_port
    internal = var.internal_port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}

# second container used to query nginx over the docker network
resource "docker_container" "client" {
  for_each = var.server_names

  name  = "server-${each.value}"
  image = "appropriate/curl:latest"

  networks_advanced {
    name    = docker_network.app.name
    aliases = ["server-${each.value}"]
  }

  command = ["sh", "-c", "curl -sS http://nginx/ && sleep 30"]

  depends_on = [docker_container.nginx]
}

# separateur cool

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  
  # LocalStack endpoint configuration
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  endpoints {
    s3       = "http://localhost:4566"
    ec2 	 = "http://localhost:4566"
  }
}