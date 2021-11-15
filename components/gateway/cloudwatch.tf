resource "aws_cloudwatch_log_group" "access" {
  name              = "${local.prefix}-access"
  retention_in_days = "3"

  tags = local.common_tags
}

locals {
  access_logs_format = {
    request = {
      requestId         = "$context.requestId"
      requestTime       = "$context.requestTime"
      extendedRequestId = "$context.extendedRequestId"
    }

    api = {
      apiId        = "$context.apiId"
      stage        = "$context.stage"
      domainName   = "$context.domainName"
      domainPrefix = "$context.domainPrefix"
    }

    client = {
      sourceIp  = "$context.identity.sourceIp"
      userAgent = "$context.identity.userAgent"
    }

    http = {
      path       = "$context.path"
      routeKey   = "$context.routeKey"
      protocol   = "$context.protocol"
      httpMethod = "$context.httpMethod"
    }

    integration = {
      integrationStatus       = "$context.integrationStatus"
      integrationLatency      = "$context.integrationLatency"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }

    error = {
      responseType  = "$context.error.responseType"
      errorMessage  = "$context.error.message"
      messageString = "$context.error.messageString"
    }

    response = {
      status          = "$context.status"
      dataProcessed   = "$context.dataProcessed"
      responseLength  = "$context.responseLength"
      responseLatency = "$context.responseLatency"
    }
  }
}