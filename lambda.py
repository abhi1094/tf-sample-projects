import boto3
import json

def create_custom_document(document_name, content):
    ssm_client = boto3.client('ssm')

    try:
        ssm_client.create_document(
            Name=document_name,
            DocumentType='Command',
            Content=content
        )
        print(f"Custom SSM document {document_name} created successfully.")
        return True
    except ssm_client.exceptions.DocumentAlreadyExists as e:
        print(f"Custom SSM document {document_name} already exists.")
        return True
    except Exception as e:
        print(f"Error creating custom SSM document: {e}")
        return False

def run_ssm_command(instance_id, document_name, script_params):
    ssm_client = boto3.client('ssm')

    try:
        response = ssm_client.send_command(
            DocumentName=document_name,
            Targets=[{"Key": "instanceids", "Values": [instance_id]}],
            Parameters={
                'commands': [f"<YourScript.ps1 {script_params}>"]
            }
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
    document_name = "MyPowerShellScriptDocument"
    script_params = "-Param1 Value1 -Param2 Value2"

    # Create custom SSM document
    document_content = """
    {
      "schemaVersion": "2.2",
      "description": "Custom PowerShell script execution document",
      "mainSteps": [
        {
          "action": "aws:runPowerShellScript",
          "name": "runPowerShellScript",
          "inputs": {
            "runCommand": ["<YourScript.ps1>"]
          }
        }
      ]
    }
    """
    create_custom_document(document_name, document_content)

    # Run SSM command
    command_id = run_ssm_command(instance_id, document_name, script_params)

    if command_id:
        # Proceed with other tasks
        print("Other tasks can be performed now.")
    else:
        print("Error occurred during SSM command execution.")

    return {
        'statusCode': 200,
        'body': f'SSM Command sent. Command ID: {command_id}'
    }
