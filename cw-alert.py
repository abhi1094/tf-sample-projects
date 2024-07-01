import json
import boto3
import os
from datetime import datetime, timedelta

logs = boto3.client('logs')
sns = boto3.client('sns')
log_group_name = os.getenv('LOG_GROUP_NAME')
sns_topic_arn = os.getenv('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    query = """
    fields @timestamp, @message, MemoryUtilized, MemoryReserved, containerId
    | filter MemoryUtilized > 0 and MemoryReserved > 0
    | filter MemoryUtilized / MemoryReserved * 100 > 80
    | stats count() as utilizationCount by containerId
    | filter utilizationCount >= 5
    """
    
    start_query_response = logs.start_query(
        logGroupName=log_group_name,
        startTime=int((datetime.utcnow() - timedelta(minutes=5)).timestamp()),
        endTime=int(datetime.utcnow().timestamp()),
        queryString=query
    )
    
    query_id = start_query_response['queryId']
    
    response = None
    while response == None or response['status'] == 'Running':
        response = logs.get_query_results(
            queryId=query_id
        )
    
    exceeded_containers = []
    for result in response['results']:
        for field in result:
            if field['field'] == 'containerId':
                exceeded_containers.append(field['value'])
    
    if exceeded_containers:
        message = f"Containers exceeding 80% memory utilization for 5 minutes: {', '.join(exceeded_containers)}"
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject="High Memory Utilization Alert"
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Query executed and notifications sent if needed')
    }
