import json
import logging
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(
            record['s3']['object']['key'],
            encoding='utf-8'
        )
        logger.info(f"Image received: {key}")
        logger.info(f"Bucket: {bucket}")
        logger.info(f"Full event: {json.dumps(record)}")

    return {
        'statusCode': 200,
        'body': json.dumps('Asset processed successfully')
    }
