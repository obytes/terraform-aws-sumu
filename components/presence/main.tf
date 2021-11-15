data "aws_region" "current" {}

locals {
  prefix = "${var.prefix}-presence"

  common_tags = {
    module = "sumu-presence"
  }
}
