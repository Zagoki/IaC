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

# Create EC2 instance with Docker app
resource "aws_instance" "web" {
  ami             = "ami-12345678"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web.name]
  key_name        = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              
              # Login to ECR (using AWS CLI)
              yum install -y awscli
              aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url}
              
              # Pull and run the app container
              docker pull ${aws_ecr_repository.app_repo.repository_url}:latest
              docker run -d -p 80:3000 --name hello-world-app ${aws_ecr_repository.app_repo.repository_url}:latest
              
              # Optional: Install Nginx as reverse proxy if needed
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              
              # Configure Nginx to proxy to the app
              cat > /etc/nginx/nginx.conf << 'NGINX_CONF'
              user nginx;
              worker_processes auto;
              error_log /var/log/nginx/error.log;
              pid /run/nginx.pid;
              
              events {
                worker_connections 1024;
              }
              
              http {
                log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                                '$status $body_bytes_sent "$http_referer" '
                                '"$http_user_agent" "$http_x_forwarded_for"';
              
                access_log /var/log/nginx/access.log main;
              
                sendfile on;
                tcp_nopush on;
                tcp_nodelay on;
                keepalive_timeout 65;
                types_hash_max_size 2048;
              
                include /etc/nginx/mime.types;
                default_type application/octet-stream;
              
                server {
                  listen 80 default_server;
                  listen [::]:80 default_server;
                  server_name _;
                  root /usr/share/nginx/html;
              
                  location / {
                    proxy_pass http://localhost:3000;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                  }
                }
              }
              NGINX_CONF
              
              systemctl reload nginx
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
