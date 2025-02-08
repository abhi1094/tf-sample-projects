provider "aws" {
  region = "us-west-2"  # Change to your AWS region
}

##############################
# VPC and Security Groups
##############################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

##############################
# IAM Role for Lambda
##############################

resource "aws_iam_role" "lambda_execution" {
  name = "lambda_mwaa_alb_execution_role"

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

resource "aws_iam_policy" "lambda_alb_policy" {
  name = "lambda_alb_register_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["elasticloadbalancing:RegisterTargets"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach_policy" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_alb_policy.arn
}

##############################
# Lambda Function Deployment
##############################

resource "aws_lambda_function" "mwaa_register_ip" {
  function_name = "mwaa-register-ip-to-alb"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda_function.zip"  # Upload your zipped Lambda function
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      MWAA_ENV_NAME     = "my-mwaa-environment"       # Replace with your MWAA environment name
      TARGET_GROUP_ARN  = "arn:aws:elasticloadbalancing:..."  # Replace with your ALB target group ARN
      AWS_REGION        = "us-west-2"
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  timeout = 60
}

##############################
# Security Group for Lambda
##############################

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-mwaa-sg"
  description = "Allow Lambda to access MWAA environment"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to your VPC CIDR
  }
}

##############################
# Lambda Execution Permissions
##############################

resource "aws_lambda_permission" "allow_alb_trigger" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mwaa_register_ip.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}
