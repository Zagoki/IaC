# Generate SSH key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.key.public_key_openssh
}

# Store private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/deployer-key.pem"
  file_permission = "0600"
}

# Create EC2 instance with Nginx
resource "aws_instance" "web" {
  ami             = "ami-12345678"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install and configure Nginx
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              
              # Create a simple webpage
              echo "<h1>Hello from Terraform and LocalStack!</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = var.instance_name
  }
}

# Create EC2 instance with Database
resource "aws_instance" "database" {
  ami             = "ami-12345678"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.database.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install and configure PostgreSQL
              yum update -y
              yum install -y postgresql15-server postgresql15-contrib
              /usr/pgsql-15/bin/initdb /var/lib/pgsql/15/data
              systemctl start postgresql-15
              systemctl enable postgresql-15
              
              # Basic configuration
              echo "PostgreSQL 15 database server is configured and running"
              EOF

  tags = {
    Name = var.db_instance_name
  }
}
