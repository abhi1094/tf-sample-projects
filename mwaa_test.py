import pytest
import boto3
from moto import mock_elbv2
from unittest.mock import patch, MagicMock
from lambda_function import lambda_handler, get_private_ip_by_nslookup, add_ip_to_target_group

# Mock Environment Variables
ENV_VARS = {
    "MWAA_ENV_NAME": "my-mwaa-environment",
    "TARGET_GROUP_ARN": "arn:aws:elasticloadbalancing:region:account-id:targetgroup/my-target-group/abc123",
    "AWS_REGION": "us-west-2"
}


@pytest.fixture
def aws_credentials():
    """Mocked AWS credentials for testing."""
    boto3.setup_default_session(
        aws_access_key_id="testing",
        aws_secret_access_key="testing",
        aws_session_token="testing"
    )


@pytest.fixture
def mock_elbv2(aws_credentials):
    """Mock AWS Elastic Load Balancing (ALB) client."""
    with mock_elbv2():
        yield boto3.client('elbv2', region_name=ENV_VARS["AWS_REGION"])


def mock_nslookup(domain_name):
    """Mock function for nslookup to return a fake private IP address."""
    if domain_name == f"{ENV_VARS['MWAA_ENV_NAME']}.vpc.internal":
        return "10.0.1.15"
    else:
        raise Exception("DNS resolution failed")


@patch.dict('os.environ', ENV_VARS)
@patch('subprocess.run')
def test_get_private_ip_by_nslookup(mock_subprocess):
    """Test the function that retrieves MWAA private IP using nslookup."""
    # Mock subprocess output
    mock_subprocess.return_value = MagicMock(
        returncode=0,
        stdout="Server: 10.0.0.2\nAddress: 10.0.0.2#53\n\nName: my-mwaa-environment.vpc.internal\nAddress: 10.0.1.15\n",
        stderr=""
    )

    ip_address = get_private_ip_by_nslookup(ENV_VARS["MWAA_ENV_NAME"])
    assert ip_address == "10.0.1.15"
    mock_subprocess.assert_called_once_with(
        ["nslookup", f"{ENV_VARS['MWAA_ENV_NAME']}.vpc.internal"],
        capture_output=True,
        text=True
    )


@patch.dict('os.environ', ENV_VARS)
def test_add_ip_to_target_group(mock_elbv2):
    """Test the function that adds an IP address to the ALB target group."""
    # Mock the client
    with mock_elbv2:
        elbv2_client = boto3.client('elbv2', region_name=ENV_VARS["AWS_REGION"])

        # Create a mock target group
        target_group_arn = ENV_VARS["TARGET_GROUP_ARN"]
        elbv2_client.create_target_group(
            Name="my-target-group",
            Protocol="HTTPS",
            Port=443,
            VpcId="vpc-12345678",
            TargetType="ip"
        )

        # Call the function to add an IP
        response = add_ip_to_target_group(target_group_arn, "10.0.1.15")

        # Assert that the target was registered
        registered_targets = elbv2_client.describe_target_health(TargetGroupArn=target_group_arn)
        assert len(registered_targets["TargetHealthDescriptions"]) == 1
        assert registered_targets["TargetHealthDescriptions"][0]["Target"]["Id"] == "10.0.1.15"


@patch.dict('os.environ', ENV_VARS)
@patch('lambda_function.get_private_ip_by_nslookup', side_effect=mock_nslookup)
@patch('lambda_function.add_ip_to_target_group')
def test_lambda_handler(mock_add_ip_to_target_group, mock_get_private_ip):
    """Test the Lambda handler function."""
    event = {}
    context = {}

    # Call the handler
    response = lambda_handler(event, context)

    # Assertions
    mock_get_private_ip.assert_called_once_with(ENV_VARS["MWAA_ENV_NAME"])
    mock_add_ip_to_target_group.assert_called_once_with(ENV_VARS["TARGET_GROUP_ARN"], "10.0.1.15")

    assert response["statusCode"] == 200
    assert "Successfully added IP address" in response["body"]
