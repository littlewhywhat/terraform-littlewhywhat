locals {
  mongodbatlas_project_id = "69d95286a50b5be9a101f813"
}

import {
  to = mongodbatlas_advanced_cluster.pet_projects
  id = "69d95286a50b5be9a101f813-pet-projects"
}

resource "mongodbatlas_advanced_cluster" "pet_projects" {
  project_id   = local.mongodbatlas_project_id
  name         = "pet-projects"
  cluster_type = "REPLICASET"

  replication_specs = [{
    region_configs = [{
      provider_name = "AWS"
      priority      = 7
      region_name   = "EU_CENTRAL_1"
      electable_specs = {
        instance_size = "M0"
        node_count    = 3
      }
    }]
  }]

  lifecycle {
    ignore_changes = all
  }
}

resource "random_password" "telegram_bot_db" {
  for_each = toset(["staging", "production"])
  length   = 32
  special  = false
}

resource "mongodbatlas_database_user" "telegram_bot" {
  for_each = toset(["staging", "production"])

  project_id         = local.mongodbatlas_project_id
  username           = "telegram-bot-${each.key}"
  password           = random_password.telegram_bot_db[each.key].result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "telegram-bot-${each.key}"
  }

  scopes {
    name = mongodbatlas_advanced_cluster.pet_projects.name
    type = "CLUSTER"
  }
}

output "telegram_bot_db_connection_strings" {
  description = "Connection strings for telegram-bot databases"
  value = {
    for env in ["staging", "production"] :
    env => {
      username          = mongodbatlas_database_user.telegram_bot[env].username
      password          = random_password.telegram_bot_db[env].result
      connection_string = mongodbatlas_advanced_cluster.pet_projects.connection_strings.standard_srv
    }
  }
  sensitive = true
}
