module "agent_hub" {
  source = "./modules/agent-hub"
  codedeploy_service_role_arn = module.code-deploy.codedeploy_role_arn
}

module "code-deploy" {
  source = "./modules/code-deploy"
}
