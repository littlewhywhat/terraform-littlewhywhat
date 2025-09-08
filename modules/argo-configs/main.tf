resource "github_repository" "argo_configs" {
  name         = "argo-configs"
  visibility   = "public"
  
  has_issues   = true
  has_wiki     = false
  has_projects = false
  
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
}

resource "github_actions_repository_permissions" "argo_configs" {
  repository = github_repository.argo_configs.name
  
  enabled = true
  allowed_actions = "all"
  
  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = true
    patterns_allowed     = ["*"]
  }
}

resource "github_branch_protection" "argo_configs_main" {
  repository_id = github_repository.argo_configs.name
  pattern       = "main"
  
  enforce_admins = false
}
