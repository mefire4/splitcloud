import boto3
import json

dynamodb = boto3.resource('dynamodb')
table_groupes = dynamodb.Table('Groupes')
table_depenses = dynamodb.Table('depenses')

def lambda_handler(event, context):
    params = event.get('queryStringParameters') or {}
    groupe_id = params.get('groupe_id')

    reponse_groupe = table_groupes.get_item(Key={'groupe_id': groupe_id})
    groupe = reponse_groupe.get('Item')

    if not groupe:
        return {'statusCode': 404, 'body': json.dumps({'erreur': 'Groupe introuvable'})}

    membres = groupe['membres']

    reponse_depenses = table_depenses.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('groupe_id').eq(groupe_id)
    )
    depenses = reponse_depenses['Items']

    total_paye_par_personne = {membre: 0 for membre in membres}
    for depense in depenses:
        payeur = depense['payeur']
        montant = depense['montant']
        total_paye_par_personne[payeur] += montant

    total_general = sum(total_paye_par_personne.values())
    part_equitable = total_general / len(membres)

    soldes = {}
    for membre in membres:
        soldes[membre] = float(total_paye_par_personne[membre]) - float(part_equitable)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'total_general': float(total_general),
            'part_equitable': round(float(part_equitable), 2),
            'soldes': {k: round(v, 2) for k, v in soldes.items()}
        }, default=str)
    }