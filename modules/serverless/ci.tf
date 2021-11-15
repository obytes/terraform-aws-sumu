module "authorizer_ci" {
  source      = "git::https://github.com/obytes/terraform-aws-lambda-ci.git//modules/ci"
  prefix      = "${local.prefix}-authorizer-ci"
  common_tags = var.common_tags

  # Lambda
  lambda                   = module.authorizer.lambda
  app_src_path             = "sources"
  packages_descriptor_path = "sources/requirements/lambda.txt"

  # Github
  s3_artifacts      = var.s3_artifacts
  github            = var.github
  pre_release       = var.pre_release
  github_repository = var.github_repositories.authorizer

  # Notifications
  ci_notifications_slack_channels = var.ci_notifications_slack_channels
}

module "pusher_ci" {
  source      = "git::https://github.com/obytes/terraform-aws-lambda-ci.git//modules/ci"
  prefix      = "${local.prefix}-pusher-ci"
  common_tags = var.common_tags

  # Lambda
  lambda                   = module.pusher.lambda
  app_src_path             = "src"
  packages_descriptor_path = "src/requirements/lambda.txt"

  # Github
  s3_artifacts      = var.s3_artifacts
  github            = var.github
  pre_release       = var.pre_release
  github_repository = var.github_repositories.pusher

  # Notifications
  ci_notifications_slack_channels = var.ci_notifications_slack_channels
}
