######################
#     VARIABLES      |
######################
variable "prefix" {}
variable "common_tags" {
  type = map(string)
}

variable "stage_name" {
  type = string
}

variable "connections_table" {
  type = object({
    name = string
    arn  = string
  })
}

variable "request_authorizer" {
  type = object({
    name       = string
    alias      = string
    alias_arn  = string
    invoke_arn = string
  })
}

variable "messages_topic" {
  type = object({
    arn  = string
    name = string
  })
}

variable "messages_queue" {
  type = object({
    arn = string
    url = string
  })
}
