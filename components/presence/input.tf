######################
#     VARIABLES      |
######################
variable "prefix" {}

variable "common_tags" {
  type = map(string)
}

variable "description" {
  default = "Tracks users presence and fanout offline and online events"
}

variable "runtime" {
  default = "python3.9"
}

variable "handler" {
  default = "main.handler"
}

variable "memory_size" {
  default = 128
}

variable "timeout" {
  default = 120
}

variable "presence_source" {}

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

variable "connections_table" {
  type = object({
    name       = string
    arn        = string
    stream_arn = string
  })
}
