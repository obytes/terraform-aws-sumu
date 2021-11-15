from __future__ import print_function

import json
import logging
import os
import time

import boto3
from boto3.dynamodb.conditions import Key

logger = logging.getLogger()
logger.setLevel(logging.WARNING)
PRESENCE_SOURCE = os.environ.get("PRESENCE_SOURCE", "queue")


def user_still_online(user_id: str):
    """
    Check if user was disconnected from all devices
    :param user_id: user principal id
    :return: True if offline False if online
    """
    resource = boto3.resource("dynamodb")
    connections_table = resource.Table(os.environ["CONNECTIONS_TABLE"])
    active_connections = connections_table.query(
        KeyConditionExpression=Key("user_id").eq(user_id)
    ).get("Items", [])
    return len(active_connections)


def publish_user_presence(user_id: str, present: bool = True, event_time: float = 0):
    """
    Notify online/offline events
    :param user_id: user principal id
    :param present: True if online False if online
    :param event_time: useful for precedence check if user
    connects/disconnects rapidly and events came unordered
    """
    event = json.dumps({
        "type": "presence",
        "message": {
            "user_id": user_id,
            "status": "ONLINE" if present else "OFFLINE",
            "timestamp": event_time
        }
    })
    attributes = dict(
        source={"DataType": "String", "StringValue": "lambda.presence.watchdog", },
        user_id={"DataType": "String", "StringValue": user_id, },
        timestamp={"DataType": "Number", "StringValue": f"{int(time.time())}", },
    )
    if PRESENCE_SOURCE == "topic":
        boto3.client("sns").publish(
            TargetArn=os.environ.get("MESSAGES_TOPIC_ARN"),
            Message=event,
            MessageAttributes=attributes
        )
    elif PRESENCE_SOURCE == "queue":
        boto3.client("sqs").send_message(
            QueueUrl=os.environ.get("MESSAGES_QUEUE_URL"),
            MessageBody=event,
            MessageAttributes=attributes
        )
    else:
        print("Subscribe to presence directly from DynamoDB stream")


def handler(event, context):
    print(event)
    try:
        for record in event["Records"]:
            event_time = record["dynamodb"]["ApproximateCreationDateTime"]
            user_id = record["dynamodb"]["Keys"]["user_id"]["S"]
            if record["eventName"] == "INSERT":
                print(f"user {user_id} is online, notify!")
                publish_user_presence(user_id, True, event_time)
            elif record["eventName"] == "REMOVE":
                print(f"user {user_id} gone offline!, check other user devices...")
                if not user_still_online(user_id):
                    print(f"user {user_id} gone offline from all devices!, notify!")
                    publish_user_presence(user_id, False, event_time)
                else:
                    print(f"user {user_id} still online on other devices, skip!")
    except Exception as error:
        logger.exception(error)
