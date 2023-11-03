provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda_function"
  output_path = "${path.module}/lambda_code.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda"
  handler      = "lambda_code.handler"
  runtime      = "python3.8"
  role         = aws_iam_role.lambda_role.arn
  filename     = data.archive_file.lambda_code.output_path

  # Other Lambda function configuration options
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_access_role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_s3_access_policy" {
  name = "lambda_s3_access_policy"

  # Define permissions for accessing S3 here
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-s3-bucket-name/*",
        "arn:aws:s3:::your-s3-bucket-name"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
  role       = aws_iam_role.lambda_role.name
}

