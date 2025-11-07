import json
import boto3
from datetime import datetime, timedelta
from decimal import Decimal

def decimal_default(obj):
    if isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    raise TypeError

def handler(event, context):
    try:
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        user_id = query_params.get('user_id')
        date_str = query_params.get('date')  # Format: 2024-12-06
        
        if not user_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'user_id is required'})
            }
        
        # Use today if no date provided
        if not date_str:
            date_str = datetime.utcnow().strftime('%Y-%m-%d')
        
        # Get user's daily goal
        dynamodb = boto3.resource('dynamodb')
        users_table = dynamodb.Table('hydrotrack-users')
        
        user_response = users_table.get_item(Key={'user_id': user_id})
        if 'Item' not in user_response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'User not found'})
            }
        
        daily_goal = user_response['Item'].get('daily_goal', 2500)
        
        # Get water logs for the date
        water_logs_table = dynamodb.Table('hydrotrack-water-logs')
        
        # Query logs for specific date
        start_time = f"{date_str}T00:00:00Z"
        end_time = f"{date_str}T23:59:59Z"
        
        response = water_logs_table.query(
            KeyConditionExpression='user_id = :user_id AND #ts BETWEEN :start AND :end',
            ExpressionAttributeNames={'#ts': 'timestamp'},
            ExpressionAttributeValues={
                ':user_id': user_id,
                ':start': start_time,
                ':end': end_time
            }
        )
        
        logs = response.get('Items', [])
        
        # Calculate analytics
        total_water = sum(int(log['amount_ml']) for log in logs)
        logs_count = len(logs)
        goal_progress = round((total_water / daily_goal) * 100, 1) if daily_goal > 0 else 0
        average_per_log = round(total_water / logs_count, 1) if logs_count > 0 else 0
        
        # Determine status
        if goal_progress >= 100:
            status = "goal_achieved"
        elif goal_progress >= 75:
            status = "on_track"
        elif goal_progress >= 50:
            status = "behind_goal"
        else:
            status = "far_behind"
        
        analytics = {
            'date': date_str,
            'user_id': user_id,
            'total_water_ml': total_water,
            'daily_goal_ml': int(daily_goal),
            'goal_progress_percent': goal_progress,
            'logs_count': logs_count,
            'average_per_log_ml': average_per_log,
            'status': status,
            'logs': logs
        }
        
        return {
            'statusCode': 200,
            'body': json.dumps(analytics, default=decimal_default)
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }