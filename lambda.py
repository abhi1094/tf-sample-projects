import boto3
from botocore.exceptions import WaiterError

def wait_until_command_executed(ssm_client, command_id):
    try:
        ssm_client.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id,
            PluginName="aws:runPowerShellScript"
        )
    except ssm_client.exceptions.InvocationDoesNotExist as e:
        raise WaiterError(
            name="SSMCommandExecuted",
            reason="SSM command execution failed.",
            last_response=None
        ) from e

def run_ssm_command(instance_id, s3_bucket, s3_prefix):
    ssm_client = boto3.client('ssm')

    # S3 script location
    script_path = f"https://s3.amazonaws.com/{s3_bucket}/{s3_prefix}/Create-ChromeVHDX.ps1"

    # SSM command parameters
    ssm_parameters = {
        "sourceType": ["S3"],
        "sourceInfo": [{"path": script_path}],
        "commandLine": [
            "Create-ChromeVHDX.ps1 -installSize 650 -vhdName Chrome -vhdS3Bucket",
            s3_bucket,
            f"-vhdMountPath 'C:\\Program Files\\Google\\' -force $true"
        ]
    }

    try:
        response = ssm_client.send_command(
            DocumentName="AWS-RunRemoteScript",
            Targets=[{"Key": "instanceids", "Values": [instance_id]}],
            Parameters=ssm_parameters
        )

        command_id = response['Command']['CommandId']
        print(f"SSM Command sent successfully. Command ID: {command_id}")

        # Wait until the SSM command execution is complete
        ssm_client.get_waiter('SSMCommandExecuted').wait(
            CommandId=command_id,
            InstanceId=instance_id,
            WaiterConfig={
                'Delay': 30,  # Wait 30 seconds between attempts
                'MaxAttempts': 60  # Retry for a maximum of 30 minutes
            }
        )

        print(f"SSM Command execution completed. Command ID: {command_id}")
        return command_id
    except ssm_client.exceptions.ClientError as e:
        print(f"Error sending or waiting for SSM command: {e}")
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
        'body': f'SSM Command sent and completed. Command ID: {command_id}'
    }
