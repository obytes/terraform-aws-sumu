######################
#     VARIABLES      |
######################

# General
# -------
variable "prefix" {}

variable "common_tags" {
  type = map(string)
}

variable "stage_name" {
  description = "The API stage name"
}

variable "apigw_endpoint" {
  description = "The api custom domain name or api invoke url"
}

# --
variable "s3_artifacts" {
  type = object({
    bucket = string
    arn    = string
  })
}

# CI
# ------------
variable "ci_notifications_slack_channels" {
  description = "Slack channel name for notifying ci pipeline info/alerts"
  type        = object({
    info  = string
    alert = string
  })
}

variable "github" {
  description = "A map of strings with GitHub specific variables"
  type        = object({
    owner          = string
    connection_arn = string
    webhook_secret = string
  })
}

variable "pre_release" {
  type    = bool
  default = true
}

variable "github_repositories" {
  type = object({
    authorizer = object({
      name   = string
      branch = string
    })
    pusher = object({
      name   = string
      branch = string
    })
  })
  default = {
    authorizer = {
      name   = "apigw-jwt-authorizer"
      branch = "main"
    }
    pusher = {
      name   = "apigw-websocket-pusher"
      branch = "main"
    }
  }
}

# --

variable "issuer_jwks_uri" {
  description = "The issuer JWKs URI"
  type        = string
}

variable "authorized_audiences" {
  description = "The list to authorized audiences (app clients), leave empty to allow all"
  type        = list(string)
  default     = []
}

variable "verify_token_expiration" {
  description = "Set to true for testing mode"
  type        = bool
}

# --
variable "presence_source" {
  type        = string
  default     = "topic"
  description = "As a user of this stack, from where you want to get presence event, topic, queue or directly from dynamodb stream"
}
