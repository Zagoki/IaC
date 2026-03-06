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

variable "machines" {
  description = "List of virtual machines to deploy with name, vCPU, disk size, and region"
  type = list(object({
    name      = string
    vcpu      = number
    disk_size = number
    region    = string
  }))

  default = [
    {
      name      = "vm-prod-1"
      vcpu      = 4
      disk_size = 100
      region    = "eu-west-1"
    },
    {
      name      = "vm-prod-2"
      vcpu      = 8
      disk_size = 200
      region    = "us-east-1"
    }
  ]

  validation {
    condition     = alltrue([for m in var.machines : m.vcpu >= 2 && m.vcpu <= 64])
    error_message = "vCPU must be between 2 and 64."
  }

  validation {
    condition     = alltrue([for m in var.machines : m.disk_size >= 20])
    error_message = "Disk size must be at least 20 GB."
  }

  validation {
    condition     = alltrue([for m in var.machines : contains(["eu-west-1", "us-east-1", "ap-southeast-1"], m.region)])
    error_message = "Region must be one of: eu-west-1, us-east-1, ap-southeast-1."
  }
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "nginx-server"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-bucket"
}

variable "http_port" {
  description = "Default HTTP port for the security group"
  type        = number
  default     = 80
}

variable "db_instance_name" {
  description = "Name of the database EC2 instance"
  type        = string
  default     = "database-server"
}
