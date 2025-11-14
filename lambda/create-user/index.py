import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('hydrotrack-users')

def handler(event, context):
    try:
        # Parse request body
        body = json.loads(event['body'])
        
        # Create user record
        user_id = body.get('user_id', str(uuid.uuid4()))
        user_data = {
            'user_id': user_id,
            'name': body['name'],
            'email': body['email'],
            'daily_goal': body.get('daily_goal', 2000),
            'created_at': datetime.utcnow().isoformat()
        }
        
        # Save to DynamoDB
        table.put_item(Item=user_data)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'User created successfully',
                'user_id': user_id
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }