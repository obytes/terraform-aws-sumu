data "aws_region" "current" {}

locals {
  prefix = "${var.prefix}-integration"

  common_tags = {module = "sumu-integration"}
}
