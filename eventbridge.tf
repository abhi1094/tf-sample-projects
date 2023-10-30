provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_cloudwatch_event_rule" "example_schedule" {
  name        = "ExampleScheduleRule"  # Replace with a unique name
  description = "Scheduled Lambda Execution"
  schedule_expression = "rate(1 hour)"  # Adjust the schedule as needed

  event_pattern = <<PATTERN
{
  "source": ["aws.events"]
}
PATTERN
}

resource "aws_lambda_permission" "example_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.example_schedule.arn
}

resource "aws_cloudwatch_event_target" "example_target" {
  rule = aws_cloudwatch_event_rule.example_schedule.name
  arn  = aws_lambda_function.example_lambda.arn
}
