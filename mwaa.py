import boto3
import subprocess
import os
import logging

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
MWAA_ENV_NAME = os.getenv("MWAA_ENV_NAME")  # MWAA environment name
TARGET_GROUP_ARN = os.getenv("TARGET_GROUP_ARN")  # ARN of the ALB target group
REGION = os.getenv("AWS_REGION", "us-west-2")  # Default AWS region

# Initialize Boto3 client for Elastic Load Balancing (ALB)
elbv2_client = boto3.client('elbv2', region_name=REGION)


def get_private_ip_by_nslookup(mwaa_env_name):
    """Get the private IP address of MWAA using nslookup."""
    try:
        # Construct the DNS name for the MWAA environment
        domain_name = f"{mwaa_env_name}.vpc.internal"

        # Run nslookup to get the private IP address
        result = subprocess.run(
            ["nslookup", domain_name],
            capture_output=True,
            text=True
        )

        # Check if the command succeeded
        if result.returncode != 0:
            raise Exception(f"nslookup failed: {result.stderr}")

        # Parse the output to extract the IP address
        output_lines = result.stdout.split("\n")
        for line in output_lines:
            if "Address" in line and not line.startswith("Server"):
                ip_address = line.split()[-1]
                logger.info(f"Resolved MWAA private IP address: {ip_address}")
                return ip_address

        raise Exception("No IP address found in nslookup output")

    except Exception as e:
        logger.error(f"Error resolving MWAA IP address: {e}")
        raise


def add_ip_to_target_group(target_group_arn, ip_address):
    """Register the private IP address with the ALB target group."""
    try:
        response = elbv2_client.register_targets(
            TargetGroupArn=target_group_arn,
            Targets=[
                {
                    'Id': ip_address,
                    'Port': 443  # Change port if necessary
                }
            ]
        )
        logger.info(f"Successfully registered IP address {ip_address} with target group {target_group_arn}.")
        return response
    except Exception as e:
        logger.error(f"Error registering target: {e}")
        raise


def lambda_handler(event, context):
    """Main Lambda function handler."""
    try:
        logger.info("Lambda function triggered.")

        # Step 1: Get the private IP address of the MWAA environment
        private_ip = get_private_ip_by_nslookup(MWAA_ENV_NAME)

        # Step 2: Add the private IP address to the ALB target group
        response = add_ip_to_target_group(TARGET_GROUP_ARN, private_ip)

        return {
            'statusCode': 200,
            'body': f"Successfully added IP address {private_ip} to target group."
        }

    except Exception as e:
        logger.error(f"Error in Lambda function: {e}")
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
