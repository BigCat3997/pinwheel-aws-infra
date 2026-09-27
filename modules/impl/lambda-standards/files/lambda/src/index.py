import json


def lambda_handler(event, context):
    """
    Simple handler invocable via Lambda Function URL.
    The 'event' body is echoed back in the response.
    """
    try:
        body = json.loads(event.get("body") or "{}")
    except (json.JSONDecodeError, TypeError):
        body = {}

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "OK", "echo": body}),
    }
