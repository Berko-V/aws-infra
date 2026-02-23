import json

def handler(event, context):
    path = (event.get("rawPath") or event.get("path") or "/")
    method = (event.get("requestContext", {}).get("http", {}).get("method")
              or event.get("httpMethod") or "GET")

    body = {
        "ok": True,
        "message": "Hello from STAGING v2 🚀",
        "method": method,
        "path": path,
    }

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }