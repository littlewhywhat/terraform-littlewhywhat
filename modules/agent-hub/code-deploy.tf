resource "aws_codedeploy_app" "agent_hub" {
  name = "agent-hub-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.agent_hub.name
  deployment_group_name = "agent-hub-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "agent-hub"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}