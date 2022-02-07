from __future__ import print_function

import json

print('Loading function')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    print("Content-Type = " + event['Content-Type'])
    print("Content-Length = " + event['Content-Length'])
    print("body = " + event['body'])

    return {
        'statusCode': '200',
        'body': event['body'],
        'headers': {
            'Content-Type': 'application/json',
        }
    }