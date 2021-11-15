output "ws_api_id" {
  value = module.gateway.ws_api_id
}

output "ws_api_stage_name" {
  value = module.gateway.ws_api_stage_name
}

# Input
output "notifications" {
  value = {
    topic = module.integration.notifications_topic
    queue = module.integration.notifications_queue
  }
}

# Output
output "messages" {
  value = {
    topic = module.integration.messages_topic
    queue = module.integration.messages_queue
  }
}

output "connections_table" {
  value = module.database.tables["connections"]
}