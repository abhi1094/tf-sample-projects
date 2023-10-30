provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_glue_catalog_database" "example_database" {
  name = "example_database" # Replace with your database name
}

resource "aws_glue_crawler" "example_crawler" {
  name                  = "example_crawler" # Replace with your crawler name
  database_name         = aws_glue_catalog_database.example_database.name
  role                 = "arn:aws:iam::123456789012:role/service-role/GlueServiceRole" # Replace with your IAM role ARN
  table_prefix          = "prefix_"
  s3_target {
    path = "s3://your-bucket-name/path/to/data" # Replace with your S3 path
  }
  schema_change_detection = "INFER"
  configuration = <<JSON
{
    "Version": 1.0,
    "Grouping": {
        "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
}
JSON
}

output "crawler_name" {
  value = aws_glue_crawler.example_crawler.name
}

output "database_name" {
  value = aws_glue_catalog_database.example_database.name
}
