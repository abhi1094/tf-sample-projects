import boto3
import time

# Replace these variables with your actual values
image_builder_name = "your-image-builder-name"
s3_bucket_name = "your-s3-bucket-name"
s3_key_prefix = "path/to/installation/files/"
ssm_document_name = "your-ssm-document-name"

# Initialize AWS clients
appstream_client = boto3.client('appstream')
ssm_client = boto3.client('ssm')

# Get the ARN of the image builder
response = appstream_client.describe_image_builders(
    Names=[image_builder_name]
)
image_builder_arn = response['ImageBuilders'][0]['Arn']

# Create an SSM document with commands to copy files from S3 and install applications
ssm_document_content = f"""
aws s3 cp s3://{s3_bucket_name}/{s3_key_prefix} C:\\InstallationFiles\\ --recursive
cd C:\\InstallationFiles
your-installation-command.exe /install /quiet  # Replace with your actual installation command
"""

# Create the SSM document
ssm_response = ssm_client.create_document(
    Name=ssm_document_name,
    DocumentType='Command',
    Content=ssm_document_content
)

# Run the SSM document on the image builder
ssm_command_response = ssm_client.send_command(
    Targets=[{'Key': 'instanceids', 'Values': [image_builder_arn]}],
    DocumentName=ssm_document_name,
)

# Wait for the SSM command to complete
command_id = ssm_command_response['Command']['CommandId']
while True:
    command_status = ssm_client.list_command_invocations(
        CommandId=command_id,
        Details=True
    )
    if command_status['CommandInvocations'][0]['Status'] in ['Pending', 'InProgress']:
        time.sleep(10)
    else:
        break

# Check the output of the SSM command
output = ssm_client.get_command_invocation(
    CommandId=command_id,
    InstanceId=image_builder_arn,
    PluginName='Command'
)['StandardOutputContent']

print("SSM Command Output:")
print(output)
