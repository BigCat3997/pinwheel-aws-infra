import base64
import gzip
import json
import logging
import os
from datetime import datetime, timezone

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
LOG_ARCHIVE_BUCKET = os.environ["LOG_ARCHIVE_BUCKET"]
LOG_ARCHIVE_PREFIX = os.environ.get("LOG_ARCHIVE_PREFIX", "cloudwatch-logs/permanent").strip("/")


def _sanitize(value: str) -> str:
    return value.strip("/").replace("/", "_").replace(":", "_").replace(" ", "_")


def lambda_handler(event, context):
    payload = json.loads(gzip.decompress(base64.b64decode(event["awslogs"]["data"])))

    if payload.get("messageType") == "CONTROL_MESSAGE":
        logger.info("Ignoring CloudWatch Logs control message")
        return {"status": "ignored", "message_type": "CONTROL_MESSAGE"}

    log_group = _sanitize(payload.get("logGroup", "unknown-log-group"))
    log_stream = _sanitize(payload.get("logStream", "unknown-log-stream"))
    timestamp = datetime.now(timezone.utc)

    object_key = (
        f"{LOG_ARCHIVE_PREFIX}/log-group={log_group}/year={timestamp:%Y}/month={timestamp:%m}/day={timestamp:%d}/"
        f"{log_stream}-{context.aws_request_id}.json"
    )

    s3.put_object(
        Bucket=LOG_ARCHIVE_BUCKET,
        Key=object_key,
        Body=json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8"),
        ContentType="application/json",
    )

    record_count = len(payload.get("logEvents", []))
    logger.info(
        "Archived %s log events from %s/%s to s3://%s/%s",
        record_count,
        log_group,
        log_stream,
        LOG_ARCHIVE_BUCKET,
        object_key,
    )

    return {
        "status": "archived",
        "record_count": record_count,
        "bucket": LOG_ARCHIVE_BUCKET,
        "key": object_key,
    }
