variable "docker_image_name" {
  description = "name of the Docker image"
  type        = string
  default     = "nginx:latest"
}

variable "container_name" {
  description = "name of the Docker container"
  type        = string
  default     = "nginx-terraform"
}

variable "external_port" {
  description = "external port exposed container"
  type        = number
  default     = 8081
}

variable "internal_port" {
  description = "internal port of container"
  type        = number
  default     = 80
}

variable "network_name" {
  description = "Docker network name for nginx and client"
  type        = string
  default     = "nginx-net"
}

variable "client_container_name" {
  description = "name of the client container"
  type        = string
  default     = "nginx-client"
}

variable "server_names" {
  description = "list of server names for client containers"
  type        = set(string)
  default     = ["alpha", "beta", "gamma"]
}
