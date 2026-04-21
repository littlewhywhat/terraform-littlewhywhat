module "ec2_service" {
  source = "./modules/ec2-service"
}

module "code-deploy" {
  source = "./modules/code-deploy"
}

output "github_management_token" {
  description = "GitHub management token"
  value       = var.github_management_token
  sensitive   = true
}

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

module "telegram_bot_template" {
  source            = "./modules/telegram-bot-template"
  project_id        = local.mongodbatlas_project_id
  cluster_name      = mongodbatlas_advanced_cluster.pet_projects.name
  connection_string = mongodbatlas_advanced_cluster.pet_projects.connection_strings.standard_srv
}

module "daily_language_tutor_bot" {
  source            = "./modules/daily-language-tutor-bot"
  project_id        = local.mongodbatlas_project_id
  cluster_name      = mongodbatlas_advanced_cluster.pet_projects.name
  connection_string = mongodbatlas_advanced_cluster.pet_projects.connection_strings.standard_srv
}

output "telegram_bot_template_db_connection_strings" {
  value     = module.telegram_bot_template.connection_strings
  sensitive = true
}

output "daily_language_tutor_bot_db_connection_strings" {
  value     = module.daily_language_tutor_bot.connection_strings
  sensitive = true
}
