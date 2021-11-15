module "database" {
  source = "../../components/database"
}

module "integration" {
  source      = "../../components/integration"
  prefix      = local.prefix
  common_tags = local.common_tags
}

module "authorizer" {
  source      = "git::https://github.com/obytes/terraform-aws-codeless-lambda.git//modules/lambda"
  prefix      = "${local.prefix}-authorizer"
  common_tags = local.common_tags

  handler = "app.main.handle"
  envs    = {
    AUTHORIZED_APIS          = join(",", module.gateway.authorized_apis)
    JWT_ISSUER_JWKS_URI      = var.issuer_jwks_uri
    JWT_AUTHORIZED_AUDIENCES = join(",", var.authorized_audiences)
    JWT_VERIFY_EXPIRATION    = var.verify_token_expiration
  }
}

module "gateway" {
  source      = "../../components/gateway"
  prefix      = local.prefix
  common_tags = local.common_tags

  stage_name         = var.stage_name
  messages_topic     = module.integration.messages_topic
  messages_queue     = module.integration.messages_queue
  connections_table  = module.database.tables["connections"]
  request_authorizer = module.authorizer.lambda
}

module "presence" {
  source      = "../../components/presence"
  prefix      = local.prefix
  common_tags = local.common_tags
  count       = contains(["topic", "queue"], var.presence_source) ? 1:0

  presence_source   = var.presence_source
  messages_topic    = module.integration.messages_topic
  messages_queue    = module.integration.messages_queue
  connections_table = module.database.tables["connections"]
}

module "pusher" {
  source = "../../components/pusher"

  prefix      = local.prefix
  common_tags = local.common_tags

  agma_arn                = module.gateway.agma_arn
  apigw_endpoint          = var.apigw_endpoint
  connections_table       = module.database.tables["connections"]
  notifications_topic_arn = module.integration.notifications_topic["arn"]
  notifications_queue_arn = module.integration.notifications_queue["arn"]
}
