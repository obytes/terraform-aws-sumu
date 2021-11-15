# Terraform AWS SUMU

![Websockets](docs/images/sockets.gif)

SUMU(live) is a Generic, Reusable and Pluggable Websocket Stack that can be hooked to any application to make it 
interactive and provide realtime capability. it consists of the following components:

## Features

- **`Connections Store`**: a DynamoDB where all users active connections are placed, sumu automatically add new
  connections to the table and delete closed connections from it and prune stale connection using TTL attribute.
  additionally, it streams **`INSERT`** and **`DELETE`** events, so other apps can track users presence.

- **`Integration Queues/Topics`**: SUMU provides an Input SNS Topic and an Input SQS Queue to receive notifications
  requests from external applications that want to notify their connected users. It also provides an Output SNS Topic and
  an Output SQS Queue for external applications to receive messages from connected users.

- **`Websocket Request JWT Authorizer`**: a request JWT Authorizer integrated with connection route, capable of
  integrating with any JWT IaaS provider (Firebase, Cognito, Auth0...) and able to verify the JWT token signature,
  expiration time and allowed audiences.

- **`Websockets API Gateway`**: SUMU provides a Websocket API Gateway with connection and disconnection routes
  integrated with DynamoDB for connections tracking, Keepalive (ping/pong) route to avoid IDLE connections termination
  and Messages (publish/send) routes integrated with SNS/SQS to fanout messages to external applications.

- **`Websockets Notifications Async Pusher`**: Serverless and Fast AWS API Gateway websockets notifications' pusher
  using Python AsyncIO for managing asynchronous and concurrent non-blocking IO calls to DynamoDB connections store and
  API Gateway management API. making it suitable for receiving notifications requests from external applications and
  broadcasting those messages to multiple users with a fast and cost-effective approach.

- **`Presence Watchdog`**: Connections Tracker for tracking all users connections and notifying external applications
  about users' presence, It can fanout **`ONLINE`** presence event whenever a user connects and **`OFFLINE`** presence
  event whenever a user closes all his connections from all devices.

## Deploy It

SUMU can be provisioned with just 2 Terraform modules, the actual sumu module and a helper module to expose the
websocket with custom domain.

```hcl
module "sumu" {
  source      = "git::https://github.com/obytes/terraform-aws-sumu//modules/serverless"
  prefix      = local.prefix
  common_tags = local.common_tags

  # Authorizer
  issuer_jwks_uri         = "https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com"
  authorized_audiences    = ["sumu-websocket", ]
  verify_token_expiration = true

  s3_artifacts = {
     arn    = aws_s3_bucket.artifacts.arn
     bucket = aws_s3_bucket.artifacts.bucket
  }
  github = {
     owner          = "obytes"
     webhook_secret = "not-secret"
     connection_arn = "arn:aws:codestar-connections:us-east-1:{ACCOUNT_ID}:connection/{CONNECTION_ID}"
  }
  github_repository               = {
    authorizer = {
      name   = "apigw-jwt-authorizer"
      branch = "main"
    }
    pusher = {
      name   = "apigw-websocket-pusher"
      branch = "main"
    }
  }
  ci_notifications_slack_channels = {
     info  = "ci-info"
     alert = "ci-alert"
  }

  stage_name      = "mvp"
  apigw_endpoint  = "https://live.kodhive.com/push"
  presence_source = "queue"
}

module "gato" {
  source      = "git::https://github.com/obytes/terraform-aws-gato//modules/core-route53"
  prefix      = local.prefix
  common_tags = local.common_tags

  # DNS
  r53_zone_id = aws_route53_zone.prerequisite.zone_id
  cert_arn    = aws_acm_certificate.prerequisite.arn
  domain_name = "kodhive.com"
  sub_domains = {
    stateless = "api"
    statefull = "live"
  }

  # Rest APIS
  http_apis = []

  ws_apis = [
    {
      id    = module.sumu.ws_api_id
      key   = "live"
      stage = module.sumu.ws_api_stage_name
    }
  ]
}
```

## Usage 

SUMU is built to be interoperable with any application, It provides an Output SNS Topic for publishing users messages to 
backends, an Output SQS Queue for queuing users messages, an Input SNS Topic for external applications to publish 
notification requests and an Input SQS queue to queue notification requests.


### Connecting users

```javascript
import Sockette from "sockette";

let endpoint = `wss://live.kodhive.com/push?authorization=${accessToken}`;
let ws = new Sockette(endpoint, {
    onopen: e => {},
    onmessage: e => {},
    onreconnect: e => {},
    onmaximum: e => {},
    onclose: e => {},
    onerror: e => {}
})
```

To keep user connections active, you can send ping frames periodically:

```javascript
import Sockette from "sockette";
let keepAliveInterval: any = null;
function keepAliveHandler() {
    ws.json({action: 'ping'});
}
function keep_alive() {
    clearInterval(keepAliveInterval)
    keepAliveInterval = setInterval(keepAliveHandler, 30000)
}
let endpoint = `wss://live.kodhive.com/push?authorization=${accessToken}`;
let ws = new Sockette(endpoint, {
    onopen: e => {keep_alive()}
})
```

### Sending messages from clients to backend

SUMU is integrated with SNS and SQS, so you can send messages to SNS or publish them to SQS queue, The message should
be a JSON String that contains the **`action`** and the actual **`message`**:

- Send a message to backend applications through SQS:

```javascript
ws.json({action: 'send', message: {text: '🦄 Wow so easy!'}});
```

- Publish a message to backend applications through SNS:

```javascript
ws.json({action: 'publish', message: {text: '🦄 Wow so easy!'}});
```

### Subscribing backends to clients messages

You can subscribe a Lambda Function as backend processor of clients messages by creating an SNS subscription and
allowing SNS to invoke the function

```hcl
resource "aws_sns_topic_subscription" "_" {
  topic_arn = var.messages_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.messages_topic_arn
}
```

> In addition to Lambda, you can publish messages to http webhook endpoints, SMS and Email.

### Polling clients messages from backends

In case you want to process clients messages in batches you can create an SQS event source and give the Lambda Function
permission to receive messages from the queue:

```hcl
resource "aws_lambda_event_source_mapping" "_" {
  enabled                            = true
  batch_size                         = 10
  event_source_arn                   = var.messages_queue_arn
  function_name                      = aws_lambda_function.this.arn
  maximum_batching_window_in_seconds = 0 # Do not wait until batch size is fulfilled
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]

    resources = [
      var.messages_queue_arn
    ]
  }
}
```

> SQS is better than SNS if you want to avoid hitting the Lambda Concurrent Execution Limit which is 1,000 (Can be
increased to 100,000 by AWS service request)

### Notifying clients from backend

Backend applications can send notifications to AWS API Gateway Websocket connected users by sending a notification
request to the service integrated with the Pusher (SNS|SQS), notifications requests should meet the following format:

For selective notifications, the message should be a JSON String that contains the list of users and the actual `data`:

```python
import json

message = {
    "users": ["783304b1-2320-44db-8f58-09c3035a686b", "a280aa41-d99b-4e1c-b126-6f39720633cc"],
    "data": {"type": "notification", "message": "A message sent to selected user"}
}
message_to_send = json.dumps(message)
```

For broadcast notifications, the same but do not provide users list or provide an empty users list:

```python
import json

message = {
    "data": {"type": "announcement", "message": "A broadcast to all users"}
}
message_to_send = json.dumps(message)
```

### Notification requests through SNS

SUMU Pusher is subscribing to notifications SNS Topic, and whenever a backend applications Publish notification requests
to SNS, the later will quickly notify the Pusher by sending the notification request to the subscribed Pusher Lambda.

This will result in a fast delivery because this approach does not introduce a polling mechanism and SNS will notify the
Pusher whenever a notification request is available. however, at scale SNS will trigger a Pusher Lambda Function for
every notification request and given that the Lambda Function Concurrent Invocations Limit is 1,000 per account (Can be
increased to 100,000 by support-ticket) notification requests will be throttled for large applications.

> Publish to SNS when you have small application with few users

```python
import os
import json
import time
import boto3

message = {
    "users": ["783304b1-2320-44db-8f58-09c3035a686b", "a280aa41-d99b-4e1c-b126-6f39720633cc"],
    "data": {
        "type": "notification",
        "message": {
            "text": "Your order has been fulfilled!",
            "timestamp": int(time.time())
        }
    }
}
boto3.client("sns").sns.publish(
    TargetArn=os.environ["NOTIFICATIONS_TOPIC_ARN"],
    Message=json.dumps(message),
)
```

### Sending notification requests through SQS

The Pusher can poll notifications from SQS queue,

Unlike SNS, when sending notifications to SQS queue, the Pusher Lambda Function event source is configured to poll
notification requests from the SQS Queue, and it will periodically poll notification requests from the Queue using
Polling Technique.

This will result in notifications requests to be processed in batches, which comes with many benefits:

- Fewer lambda function executions, to not reach the Lambda Concurrent Execution Limit.
- As the pusher uses AsyncIO, it will be able to process batches of SQS Records concurrently.
- Low cost thanks to SQS batches and fewer Lambda Executions.

SUMU meets the same speed and performance of SNS because the SQS queue **`receive_wait_time_seconds`** is set to 0. this
will make the Lambda Function do Short Polling instead of Long Polling. and it will receive the notifications requests
immediately after being visible on SQS queue.

> Send to SQS when you have a large application with millions of users

```python
import os
import json
import time
import boto3

message = {
    "users": ["783304b1-2320-44db-8f58-09c3035a686b", "a280aa41-d99b-4e1c-b126-6f39720633cc"],
    "data": {
        "type": "notification",
        "message": {
            "text": "Your order has been fulfilled!",
            "timestamp": int(time.time())
        }
    }
}
boto3.client("sqs").send_message(
  QueueUrl=os.environ.get("NOTIFICATIONS_QUEUE_URL"),
  MessageBody=json.dumps(message),
)
```

