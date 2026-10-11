import os
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError

import boto3

_REGION = os.environ.get("AWS_REGION", "us-east-1")

# Use the regional endpoint so the S3 interface VPC endpoint private DNS resolves
# correctly (covers *.s3.<region>.amazonaws.com, not the global s3.amazonaws.com).
_S3 = boto3.client(
    "s3",
    region_name=_REGION,
    endpoint_url=f"https://s3.{_REGION}.amazonaws.com",
    config=Config(
        connect_timeout=1,
        read_timeout=2,
        retries={"max_attempts": 1, "mode": "standard"},
        s3={"addressing_style": "virtual"},
    ),
)


def _load_html_from_s3() -> tuple[str, str, str]:
  bucket_name = os.environ["BUCKET_NAME"]
  object_key = os.environ.get("OBJECT_KEY", "index.html")

  response = _S3.get_object(
      Bucket=bucket_name,
      Key=object_key
  )

  content_type = response.get("ContentType", "text/html; charset=utf-8")
  content_disposition = response.get("ContentDisposition", "inline")
  html_body = response["Body"].read().decode("utf-8")

  return html_body, content_type, content_disposition

def _response(status_code: int, body: str, content_type: str = "text/html; charset=utf-8", content_disposition: str = "inline") -> dict:
    reason = {
        200: "OK",
        503: "Service Unavailable",
    }.get(status_code, "OK")

    return {
        "statusCode": status_code,
        "statusDescription": f"{status_code} {reason}",
        "isBase64Encoded": False,
        "headers": {
            "Content-Type": content_type,
            "Content-Disposition": content_disposition,
            "Cache-Control": "no-store, no-cache, must-revalidate",
        },
        "body": body,
    }


def _is_alb_health_check(event: dict) -> bool:
    headers = (event or {}).get("headers") or {}
    user_agent = headers.get("user-agent") or headers.get("User-Agent") or ""

    return "ELB-HealthChecker" in user_agent


def lambda_handler(event, context):
    if _is_alb_health_check(event):
        return _response(200, "ok")

    try:
        html_body, content_type, content_disposition = _load_html_from_s3()
        return _response(200, html_body, content_type, content_disposition)
    except (KeyError, TimeoutError, ValueError, ClientError, BotoCoreError) as exc:
        return _response(503, f"Service temporarily unavailable: {exc}")