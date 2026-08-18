import boto3
import json
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Groupes')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    nom_groupe = body['nom']
    membres = body['membres']

    groupe_id = str(uuid.uuid4())

    table.put_item(Item={
        'groupe_id': groupe_id,
        'nom': nom_groupe,
        'membres': membres
    })

    return {
        'statusCode': 200,
        'body': json.dumps({'groupe_id': groupe_id, 'message': 'Groupe créé'})
    }