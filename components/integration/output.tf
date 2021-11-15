# Output: Used by publish route
output "messages_topic" {
  value = {
    name = aws_sns_topic.messages.name
    arn  = aws_sns_topic.messages.arn
  }
}

# Output: Used by send route
output "messages_queue" {
  value = {
    arn  = aws_sqs_queue.messages.arn
    url  = aws_sqs_queue.messages.id
    name = aws_sqs_queue.messages.name
  }
}

# Input: Used by backend apps
output "notifications_topic" {
  value = {
    name = aws_sns_topic.notifications.name
    arn  = aws_sns_topic.notifications.arn
  }
}

# Input: Used by backend apps
output "notifications_queue" {
  value = {
    arn  = aws_sqs_queue.notifications.arn
    url  = aws_sqs_queue.notifications.id
    name = aws_sqs_queue.notifications.name
  }
}
