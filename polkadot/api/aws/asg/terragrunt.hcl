terraform {
//  source = "github.com/geometry-labs/terraform-polkadot-aws-asg.git?ref=${local.vars.versions.asg}"
  source = "source/asg"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.run
  network = find_in_parent_folders("network")
  cluster = find_in_parent_folders("k8s-cluster")
}

dependencies {
  paths = [local.network, local.cluster]
}

dependency "network" {
  config_path = local.network
  skip_outputs = !local.vars.create_network
  mock_outputs = {
    vpc_id = "tmp"
    public_subnets = ["tmp"]
    api_security_group_id = "tmp"
    consul_security_group_id = "tmp"
    monitoring_security_group_id = "tmp"
  }
}

dependency "cluster" {
  config_path = local.cluster
  skip_outputs = !local.vars.create_k8s
  mock_outputs = {
    cluster_id = "tmp"
  }
}

inputs = {
  security_groups = local.vars.create_network ? [
    dependency.network.outputs.api_security_group_id,
    dependency.network.outputs.consul_security_group_id,
    dependency.network.outputs.monitoring_security_group_id,
  ] : local.vars.asg_security_groups
  subnet_ids = local.vars.create_network ? dependency.network.outputs.public_subnets : local.vars.asg_subnet_ids
  vpc_id = local.vars.create_network ? dependency.network.outputs.vpc_id : local.vars.asg_vpc_id
  cluster_name = local.vars.create_k8s ? dependency.cluster.outputs.cluster_id : local.vars.cluster_id
}
