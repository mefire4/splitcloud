import boto3
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('depenses')

def lambda_handler(event, context):
    params = event.get('queryStringParameters') or {}
    groupe_id = params.get('groupe_id')

    if not groupe_id:
        return {
            'statusCode': 400,
            'body': json.dumps({'erreur': 'groupe_id manquant'})
        }

    reponse = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('groupe_id').eq(groupe_id)
    )

    depenses = reponse['Items']

    return {
        'statusCode': 200,
        'body': json.dumps(depenses, default=str)
    }