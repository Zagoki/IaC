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
}//test

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
