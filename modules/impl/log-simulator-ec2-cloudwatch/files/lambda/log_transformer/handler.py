"""Firehose transformation Lambda for CloudWatch Logs subscription data.

CloudWatch Logs delivers each record as a gzip-compressed JSON envelope. This
function unpacks it and emits one newline-delimited JSON object per log event,
so the batched objects Firehose writes to S3 are directly queryable (Athena).
"""
import base64
import gzip
import json


def _transform(record):
    payload = json.loads(gzip.decompress(base64.b64decode(record["data"])))

    if payload.get("messageType") == "CONTROL_MESSAGE":
        return {"recordId": record["recordId"], "result": "Dropped", "data": record["data"]}

    lines = "".join(
        json.dumps(
            {
                "timestamp": event["timestamp"],
                "log_group": payload["logGroup"],
                "log_stream": payload["logStream"],
                "message": event["message"],
            },
            separators=(",", ":"),
        )
        + "\n"
        for event in payload["logEvents"]
    )
    return {
        "recordId": record["recordId"],
        "result": "Ok",
        "data": base64.b64encode(lines.encode("utf-8")).decode("ascii"),
    }


def lambda_handler(event, _context):
    output = []
    for record in event["records"]:
        try:
            output.append(_transform(record))
        except Exception:  # bad record is routed to the errors/ prefix, not retried forever
            output.append({"recordId": record["recordId"], "result": "ProcessingFailed", "data": record["data"]})
    return {"records": output}
