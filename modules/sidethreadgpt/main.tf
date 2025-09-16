resource "github_repository" "sidethreadgpt" {
  name         = "sidethreadgpt"
  visibility   = "private"
  
  has_issues   = true
  has_wiki     = false
  has_projects = false
  
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
}

output "github_repository_name" {
  description = "Name of the GitHub repository"
  value       = github_repository.sidethreadgpt.name
}