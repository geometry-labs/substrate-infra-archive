terraform {
  source = "github.com/geometry-labs/terraform-polkadot-k8s-config.git?ref=${local.vars.versions.k8s-config}"

  before_hook "update_kubeconfig" {
    commands     = ["apply", "destroy"]
    execute      = split(" ", "aws eks --region ${local.vars.region} update-kubeconfig --name ${local.vars.cluster_name}")
  }
}

skip = !local.vars.create_k8s

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.run

  cluster = find_in_parent_folders("k8s-cluster")
  asg = find_in_parent_folders("asg")
  network = find_in_parent_folders("network")
}

dependencies {
  paths = [local.cluster, local.asg, local.network]
}

dependency "cluster" {
  config_path = local.cluster
  mock_outputs = {
    cluster_id = "tmp"
    worker_iam_role_arn = "tmp"
    kubeconfig = "tmp"
    cluster_endpoint = "tmp"
    cluster_certificate_authority_data = base64encode("tmp")
  }
}

dependency "asg" {
  config_path = local.asg
  mock_outputs = {
    dns_name = "tmp"
  }
}

dependency "network" {
  config_path = local.network
  skip_outputs = !local.vars.create_network
  mock_outputs = {
    public_regional_domain = "tmp"
  }
}

inputs = {
  cluster_id = dependency.cluster.outputs.cluster_id
  cloud_platform = local.vars.provider
  lb_endpoint = dependency.asg.outputs.dns_name
  aws_worker_arn = dependency.cluster.outputs.worker_iam_role_arn
  deployment_domain_name = local.vars.create_network ? dependency.network.outputs.public_regional_domain : local.vars.deployment_domain_name
  kubeconfig = base64encode(dependency.cluster.outputs.kubeconfig)
}

generate "provider" {
  path = "kubernetes.tf"
  if_exists = "overwrite"
  contents =<<-EOF
data "aws_eks_cluster_auth" "this" {
  name = "${dependency.cluster.outputs.cluster_id}"
}

provider "aws" {
  region = "${local.vars.region}"
  skip_get_ec2_platforms     = true
  skip_metadata_api_check    = true
  skip_region_validation     = true
  skip_requesting_account_id = true
}

provider "helm" {
  version = "=1.1.1"
  kubernetes {
    host                   = "${dependency.cluster.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.cluster.outputs.cluster_certificate_authority_data}")
    token                  = data.aws_eks_cluster_auth.this.token
    load_config_file       = false

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = "${dependency.cluster.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.cluster.outputs.cluster_certificate_authority_data}")
  token                  = data.aws_eks_cluster_auth.this.token

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", "${local.cluster_name}"]
    command     = "aws"
  }
}
EOF
}

