import json
import logging
import random
import uuid

logger = logging.getLogger()
logger.setLevel(logging.INFO)

MESSAGES = {
    "INFO": ["User logged in", "Order created", "Cache refreshed", "Health check ok"],
    "WARNING": ["Slow query detected", "Retrying request", "Disk usage at 85%"],
    "ERROR": [
        "Database connection timeout",
        "Payment failed",
        "NullPointerException in OrderService",
    ],
}
WEIGHTS = {"INFO": 70, "WARNING": 20, "ERROR": 10}


def lambda_handler(event, context):
    count = random.randint(5, 20)
    for _ in range(count):
        level = random.choices(list(WEIGHTS), weights=list(WEIGHTS.values()))[0]
        logger.log(
            getattr(logging, level),
            json.dumps(
                {
                    "level": level,
                    "message": random.choice(MESSAGES[level]),
                    "request_id": str(uuid.uuid4()),
                    "latency_ms": random.randint(5, 3000),
                }
            ),
        )
    return {"status": "ok", "logs_written": count}
