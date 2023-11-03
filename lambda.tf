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
  name = "lambda_role"
  
  # Define permissions for your Lambda function
  # ...
}
