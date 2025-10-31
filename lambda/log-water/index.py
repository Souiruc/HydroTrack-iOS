import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('hydrotrack-water-logs')

def handler(event, context):
    try:
        # Parse request body
        body = json.loads(event['body'])
        
        # Generate unique log ID
        log_id = str(uuid.uuid4())
        
        # Create water log record
        log_data = {
            'user_id': body['user_id'],
            'timestamp': body.get('timestamp', datetime.utcnow().isoformat()),
            'amount_ml': body['amount_ml'],
            'log_id': log_id,
            'created_at': datetime.utcnow().isoformat()
        }
        
        # Save to DynamoDB
        table.put_item(Item=log_data)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Water log created successfully',
                'log_id': log_id
            })
        }
        
    except KeyError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': f'Missing required field: {str(e)}'
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