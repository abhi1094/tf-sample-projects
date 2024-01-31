provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

resource "aws_amplify_app" "example_app" {
  name       = "your-amplify-app-name"
  repository = "manual"  # Set repository type to "manual"

  custom_headers {
    "Access-Control-Allow-Origin" = "*"
  }
}

resource "aws_amplify_branch" "example_branch" {
  app_id      = aws_amplify_app.example_app.id
  branch_name = "main"  # Replace with your branch name
}

resource "aws_amplify_domain" "example_domain" {
  domain_name  = "your-amplify-domain-name"
  subdomain    = "www"  # Replace with your desired subdomain
  app_id       = aws_amplify_app.example_app.id
}


version: 1
frontend:
  phases:
    preBuild:
      commands:
        - echo "No build steps required for static HTML deployment"
  artifacts:
    baseDirectory: static_html
    files:
      - '**/*'
