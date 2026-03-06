# Create an S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Upload a file to the bucket
resource "aws_s3_object" "demo_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "hello-world.txt"
  source = "./test-file.txt"
  etag   = filemd5("./test-file.txt")
}