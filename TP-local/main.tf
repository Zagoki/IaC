terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Configure Docker provider to use AWS ECR
provider "docker" {
  registry_auth {
    address  = "${aws_ecr_repository.app_repo.repository_url}"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

# Data source for ECR authorization token
data "aws_ecr_authorization_token" "token" {}

# ECR repository for the app image
resource "aws_ecr_repository" "app_repo" {
  name = "hello-world-app"
}

# Build and push Docker image to ECR
resource "docker_image" "app_image" {
  name = "${aws_ecr_repository.app_repo.repository_url}:latest"
  build {
    context    = "./app"
    dockerfile = "Dockerfile"
  }
}

resource "docker_registry_image" "app_registry" {
  name = docker_image.app_image.name
}