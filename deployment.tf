locals {
  template = file("${path.module}/etc/Deployment/deployment_bae.tmpl")
  deployment_bae = replace(local.template, "ecr_url", module.ecr.ecr_repository_url)
}

resource "local_file" "deployment_bae" {
  content  = local.deployment_bae
  filename = "${path.module}/etc/Deployment/deployment_bae.yaml"

  depends_on = [module.ecr]
}