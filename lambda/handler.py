import json
import boto3
import os

# Environment variables
table_name = os.environ["TABLE_NAME"]
stage = os.environ.get("STAGE", "dev")

# AWS clients
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)


def handler(event, context):
    """
    Handles API Gateway proxy requests.

    Routes:
    - /            -> health / hello response (no DB access)
    - /items       -> write + read from DynamoDB
    """

    path = event.get("path", "/") or "/"

    # Normalize path: remove trailing slash except for root
    if path != "/" and path.endswith("/"):
        path = path[:-1]

    # Base / health route
    if path == "/":
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "OK",
                "path": path
            })
        }

    # /items route
    if path == "/items":
        table.put_item(Item={
            "id": context.aws_request_id
        })

        items = table.scan().get("Items", [])

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "items",
                "count": len(items),
                "items": items
            })
        }

    # Unknown route
    return {
        "statusCode": 404,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Not Found",
            "path": path
        })
    }