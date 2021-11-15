###############################################
#                   Archive                   |
#       Package the lambda in a zip file      |
###############################################
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/sources/dist.zip"
  source_dir  = "${path.module}/sources"
}

###############################################
#                    Lambda                   |
#              Python based lambda            |
###############################################
resource "aws_lambda_function" "function" {
  function_name = local.prefix
  role          = aws_iam_role.role.arn
  # runtime
  runtime = var.runtime
  handler = var.handler
  # resources
  memory_size = var.memory_size
  timeout     = var.timeout
  # package
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CONNECTIONS_TABLE  = var.connections_table.name
      MESSAGES_TOPIC_ARN = var.messages_topic.arn
      MESSAGES_QUEUE_URL = var.messages_queue.url
      PRESENCE_SOURCE    = var.presence_source
    }
  }

  tags = merge(
    local.common_tags,
    {description = var.description}
  )
  depends_on = [data.archive_file.lambda_zip]
}
