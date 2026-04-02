import html
import os
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


def _public_object_url() -> str:
    bucket_name = os.environ["BUCKET_NAME"]
    object_key = os.environ.get("OBJECT_KEY", "index.html")
    region = os.environ.get("AWS_REGION", "us-east-1")
    encoded_key = "/".join(quote(part) for part in object_key.split("/"))

    return f"https://{bucket_name}.s3.{region}.amazonaws.com/{encoded_key}"


def _load_html_from_s3() -> tuple[str, str, str]:
    request = Request(
        _public_object_url(),
        headers={"User-Agent": "alb-maintenance-lambda/1.0"},
    )

    with urlopen(request, timeout=5) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        html_body = response.read().decode(charset)
        content_type = response.headers.get("Content-Type", "text/html; charset=utf-8")
        content_disposition = response.headers.get("Content-Disposition", "inline")

    return html_body, content_type, content_disposition


def _fallback_page(message: str) -> str:
    safe_message = html.escape(message)

    return f"""<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
    <title>Maintenance</title>
    <style>
      body {{
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        font-family: Arial, sans-serif;
        background: #0f172a;
        color: #e2e8f0;
      }}
      .box {{
        width: min(680px, calc(100% - 32px));
        padding: 32px;
        border-radius: 16px;
        background: #111827;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.35);
      }}
      .pill {{
        display: inline-block;
        margin-bottom: 14px;
        padding: 6px 12px;
        border-radius: 999px;
        background: #f59e0b;
        color: #111827;
        font-weight: 700;
      }}
      p {{ line-height: 1.6; }}
      code {{ color: #93c5fd; }}
    </style>
  </head>
  <body>
    <div class=\"box\">
      <div class=\"pill\">Maintenance mode</div>
      <h1>We will be back shortly</h1>
      <p>The application is temporarily routed to the maintenance landing page.</p>
      <p><strong>Reason:</strong> <code>{safe_message}</code></p>
    </div>
  </body>
</html>"""


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
    except (KeyError, HTTPError, URLError, TimeoutError, ValueError) as exc:
        return _response(503, _fallback_page(str(exc)))
    except Exception as exc:
        return _response(503, _fallback_page(f"unexpected error: {exc}"))
