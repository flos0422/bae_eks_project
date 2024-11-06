locals {
  lb_iam_role_name = "AWSLoadBalancerControllerIAMPolicy"
  lb_service_account_name = "aws-load-balancer-controller"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = "${local.default_name}-eks"
}

module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name        = local.lb_iam_role_name
  role_description = "AWS Load Balancer Controller for EKS"

  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.lb_service_account_name}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  depends_on = [ module.eks ]
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${local.lb_iam_role_name}-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("${path.module}/lb_controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
  role       = module.lb_controller_role.iam_role_name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    token = data.aws_eks_cluster_auth.eks_auth.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

resource "helm_release" "release" {
  depends_on = [ module.eks ]
  
  name = local.lb_service_account_name
  chart = local.lb_service_account_name
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = {
      "clusterName" = module.eks.cluster_name
      "serviceAccount.create" = "true"
      "serviceAccount.name"   = local.lb_service_account_name
      "region" = "ap-northeast-2"
      "vpcId" = module.vpc.vpc_id
      "image.repository" = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"

      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.lb_controller_role.iam_role_arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}