import json
import boto3
import os

table_name = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)

def handler(event, context):
    table.put_item(Item={
        "id": context.aws_request_id
    })

    items = table.scan()["Items"]

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from AWS Free Tier",
            "items": items
        })
    }