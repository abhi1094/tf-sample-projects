provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_sfn_state_machine" "example_state_machine" {
  name     = "MyStateMachine"
  role_arn = "arn:aws:iam::123456789012:role/step-functions-role" # Replace with your IAM role ARN
  definition = <<EOF
{
  "Comment": "An example Step Functions state machine that orchestrates Glue jobs.",
  "StartAt": "RunGlueJob",
  "States": {
    "RunGlueJob": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "my-glue-job",  # Replace with your Glue job name
        "Arguments": {
          # Define your Glue job arguments here, if any
        }
      },
      "ResultPath": null,
      "End": true,
      "Catch": [
        {
          "ErrorEquals": ["States.TaskFailed"],
          "Next": "FailureState"
        }
      }
    },
    "FailureState": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-east-1:123456789012:MySNSTopic", # Replace with your SNS topic ARN
        "Message": "The Glue job has failed!"
      },
      "End": true
    }
  }
}
EOF
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.example_state_machine.arn
}
