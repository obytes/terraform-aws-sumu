module "sumu" {
  source      = "./modules/serverless"
  prefix      = var.prefix
  common_tags = var.common_tags

  stage_name     = var.stage_name
  apigw_endpoint = var.apigw_endpoint

  issuer_jwks_uri         = var.issuer_jwks_uri
  authorized_audiences    = var.authorized_audiences
  verify_token_expiration = var.verify_token_expiration

  s3_artifacts                    = var.s3_artifacts
  github                          = var.github
  github_repositories             = var.github_repositories
  ci_notifications_slack_channels = var.ci_notifications_slack_channels

  presence_source = var.presence_source
}
