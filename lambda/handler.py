import json
import os
import boto3


def _resp(status_code: int, body: dict | str, *, cors: bool = True):
    headers = {
        "Content-Type": "application/json",
    }

    if cors:
        headers.update({
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,PUT,PATCH,DELETE,OPTIONS",
        })

    return {
        "statusCode": status_code,
        "headers": headers,
        "body": json.dumps(body) if isinstance(body, (dict, list)) else json.dumps({"message": body}),
    }


def _normalize_path(event) -> str:
    path = event.get("path") or "/"
    if path != "/" and path.endswith("/"):
        path = path[:-1]
    return path



def root_handler(event, context):
    """API Gateway (REST v1) Lambda proxy handler for the root route.

    Route:
    - / -> health check
    """

    # Preflight / CORS
    if (event.get("httpMethod") or "").upper() == "OPTIONS":
        return _resp(200, {"ok": True})

    return _resp(200, {
        "message": "OK",
        "path": _normalize_path(event),
        "function": "root",
    })


def items_handler(event, context):
    """API Gateway (REST v1) Lambda proxy handler for the items route.

    Route:
    - /items -> write + read from DynamoDB
    """

    # Preflight / CORS
    if (event.get("httpMethod") or "").upper() == "OPTIONS":
        return _resp(200, {"ok": True})

    table_name = os.environ.get("TABLE_NAME")
    if not table_name:
        return _resp(500, {
            "error": "TABLE_NAME env var is not set",
            "hint": "Set TABLE_NAME in the Lambda environment variables via Terraform",
        })

    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(table_name)

    table.put_item(Item={
        "id": context.aws_request_id,
    })

    items = table.scan().get("Items", [])
    return _resp(200, {
        "message": "items",
        "count": len(items),
        "items": items,
    })