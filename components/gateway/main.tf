locals {
  prefix      = "${var.prefix}-gw"
  common_tags = merge(var.common_tags, {"module" = "sumu-gw"})
}
