import boto3
import json
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('depenses')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    groupe_id = body['groupe_id']
    payeur = body['payeur']
    montant = body['montant']
    description = body.get('description', '')

    depense_id = str(uuid.uuid4())

    table.put_item(Item={
        'groupe_id': groupe_id,
        'depense-SortKey': depense_id,
        'payeur': payeur,
        'montant': montant,
        'description': description
    })

    return {
        'statusCode': 200,
        'body': json.dumps({'depense_id': depense_id, 'message': 'Dépense ajoutée'})
    }