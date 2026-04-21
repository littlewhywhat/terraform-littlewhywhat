terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "connection_string" {
  type = string
}

resource "random_password" "this" {
  for_each = toset(["staging"])
  length   = 32
  special  = false
}

resource "mongodbatlas_database_user" "this" {
  for_each = toset(["staging"])

  project_id         = var.project_id
  username           = "daily-language-tutor-bot-${each.key}"
  password           = random_password.this[each.key].result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "daily-language-tutor-bot-${each.key}"
  }

  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }
}

output "connection_strings" {
  value = {
    for env in ["staging"] :
    env => {
      username          = mongodbatlas_database_user.this[env].username
      password          = random_password.this[env].result
      connection_string = var.connection_string
    }
  }
  sensitive = true
}
