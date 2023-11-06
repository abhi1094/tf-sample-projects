provider "aws" {
  region = "us-west-2"  # replace with your AWS region
}

variable "bucket_names" {
  description = "List of S3 bucket names"
  type        = list(string)
  default     = ["bucket1", "bucket2", "bucket3", "bucket4", "bucket5"]  # replace with your bucket names
}

resource "aws_s3_bucket" "bucket" {
  for_each = toset(var.bucket_names)

  bucket = each.key
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  for_each = toset(var.bucket_names)

  bucket = aws_s3_bucket.bucket[each.key].id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

provider "aws" {
 region = "us-west-2"
}

resource "aws_s3_bucket" "example" {
 bucket = "my-example-bucket"

 versioning {
    enabled = true
 }

 server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
 }
}

resource "aws_s3_bucket_policy" "example" {
 bucket = aws_s3_bucket.example.id

 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
 })
}

https://a5d29dec09bcb4bf1964475be829cf92-1924209159.eu-west-1.elb.amazonaws.com/
