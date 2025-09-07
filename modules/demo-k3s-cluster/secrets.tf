# Create secrets for GitLab integration using remote-exec
resource "null_resource" "create_gitlab_secrets" {
  depends_on = [null_resource.install_argo]

  triggers = {
    gitlab_token         = var.demo_coding_agent_gitlab_token
    gitlab_webhook_secret = var.demo_coding_agent_gitlab_webhook_secret
    cursor_token         = var.demo_coding_agent_cursor_token
    gitlab_username      = var.demo_coding_agent_gitlab_username
    gitlab_email         = var.demo_coding_agent_gitlab_email
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.demo_k3s_cluster.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/demo-k3s-cluster-key")
    }
    inline = [
      "export KUBECONFIG=/home/ubuntu/.kube/config",
      
      # Wait for argo namespace to be ready
      "kubectl wait --for=condition=ready namespace/argo --timeout=60s || true",
      
      # Create GitLab webhook and API secrets
      "kubectl create secret generic demo-coding-agent-gitlab-secret --from-literal=token='${var.demo_coding_agent_gitlab_token}' --from-literal=webhook-secret='${var.demo_coding_agent_gitlab_webhook_secret}' -n argo --dry-run=client -o yaml | kubectl apply -f -",
      
      # Create workflow runtime secrets
      "kubectl create secret generic demo-coding-agent-workflow-secrets --from-literal=gitlab-token='${var.demo_coding_agent_gitlab_token}' --from-literal=cursor-token='${var.demo_coding_agent_cursor_token}' -n argo --dry-run=client -o yaml | kubectl apply -f -",
      
      # Create container registry secret
      "kubectl create secret docker-registry demo-coding-agent-gitlab-registry --docker-server=registry.gitlab.com --docker-username='${var.demo_coding_agent_gitlab_username}' --docker-password='${var.demo_coding_agent_gitlab_token}' --docker-email='${var.demo_coding_agent_gitlab_email}' -n argo --dry-run=client -o yaml | kubectl apply -f -",
      
      # Verify secrets were created
      "echo 'Verifying secrets:'",
      "kubectl get secrets -n argo | grep -E '(demo-coding-agent-gitlab-secret|demo-coding-agent-workflow-secrets|demo-coding-agent-gitlab-registry)'"
    ]
  }
}
