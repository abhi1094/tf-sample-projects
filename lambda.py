import boto3
import json

def run_ssm_command(instance_id, s3_bucket, s3_prefix):
    ssm_client = boto3.client('ssm')

    # S3 script location
    script_path = f"https://s3.amazonaws.com/{s3_bucket}/{s3_prefix}/Create-ChromeVHDX.ps1"

    # SSM command parameters
    ssm_parameters = {
        "sourceType": ["S3"],
        "sourceInfo": [{"path": script_path}],
        "commandLine": [
            "Create-ChromeVHDX.ps1",
            "-installSize", "650",
            "-vhdName", "Chrome",
            "-vhdS3Bucket", s3_bucket,
            "-vhdMountPath", "C:\\Program Files\\Google\\",
            "-force", "$true"
        ]
    }

    try:
        response = ssm_client.send_command(
            DocumentName="AWS-RunRemoteScript",
            Targets=[{"Key": "instanceids", "Values": [instance_id]}],
            Parameters=json.dumps(ssm_parameters)
        )

        command_id = response['Command']['CommandId']
        print(f"SSM Command sent successfully. Command ID: {command_id}")
        return command_id
    except ssm_client.exceptions.ClientError as e:
        print(f"Error sending SSM command: {e}")
        return None

def lambda_handler(event, context):
    # Replace with your actual values
    instance_id = "i-XXXXXXXXXXXXX"
    s3_bucket = "BUCKET-NAME"
    s3_prefix = "PREFIX"

    # Run SSM command
    command_id = run_ssm_command(instance_id, s3_bucket, s3_prefix)

    if command_id:
        # Proceed with other tasks
        print("Other tasks can be performed now.")
    else:
        print("Error occurred during SSM command execution.")

    return {
        'statusCode': 200,
        'body': f'SSM Command sent. Command ID: {command_id}'
    }
