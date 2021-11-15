resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${local.prefix}"
  retention_in_days = 1

  tags = merge(
    local.common_tags,
    {description = var.description}
  )
}
