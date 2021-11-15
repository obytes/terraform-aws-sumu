locals {
  prefix      = "${var.prefix}-sumu"
  common_tags = merge(var.common_tags, {stack = "sumu"})
}
