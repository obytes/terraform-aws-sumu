# Integration role
resource "aws_iam_role" "_" {
  name               = var.prefix
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  path               = "/"
}
data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      var.request_authorizer.alias_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      var.connections_table.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]

    resources = [
      var.messages_topic.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      var.messages_queue.arn,
    ]
  }
}
resource "aws_iam_policy" "_" {
  name   = local.prefix
  policy = data.aws_iam_policy_document.policy.json
  path   = "/"
}
resource "aws_iam_role_policy_attachment" "_" {
  policy_arn = aws_iam_policy._.arn
  role       = aws_iam_role._.name
}
