provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_cloudwatch_log_group" "example_log_group" {
  name              = "/aws/s3/bucket-policy-change-logs"
  retention_in_days = 30  # Set the desired retention period for logs
}

resource "aws_cloudwatch_log_metric_filter" "example_metric_filter" {
  name           = "S3BucketPolicyChangeFilter"
  pattern        = "{$.eventName = PutBucketPolicy}"
  log_group_name = aws_cloudwatch_log_group.example_log_group.name
}

resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "S3BucketPolicyChangeAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "S3BucketPolicyChangeFilter"
  namespace           = "CWLogs"
  period              = 300
  statistic           = "SampleCount"
  threshold           = 1
  alarm_description   = "S3 Bucket Policy Change Detected"
  alarm_action {
    arn = "arn:aws:sns:us-east-1:123456789012:MySnsTopic"  # Replace with your SNS topic ARN
  }

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.example_log_group.name
  }

  alarm_description = "S3 Bucket Policy Change Detected"
}
