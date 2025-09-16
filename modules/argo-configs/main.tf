resource "github_repository" "argo_configs" {
  name         = "argo-configs"
  visibility   = "private"
  
  has_issues   = true
  has_wiki     = false
  has_projects = false
  
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
}
