import json
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = 'cg-s3-version-bypass-' + event.get("cgid", "")
    key = 'flag.txt'

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        flag = response['Body'].read().decode()
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'flag': flag.strip()})
        }
    except Exception as e:
        return {
            'statusCode': 403,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
