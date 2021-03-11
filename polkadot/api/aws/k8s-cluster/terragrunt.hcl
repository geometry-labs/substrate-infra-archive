terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-eks.git?ref=${local.vars.versions.k8s-cluster}"
}

include {
  path = find_in_parent_folders()
}

skip = !local.vars.create_k8s

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.run
  id = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.id
  network = find_in_parent_folders("network")
}

dependencies {
  paths = [local.network]
}

dependency "network" {
  config_path = local.network
  skip_outputs = !local.vars.create_network
  mock_outputs = {
    vpc_id = "tmp"
    public_subnets = ["tmp"]
    k8s_security_group_id = "tmp"
    consul_security_group_id = "tmp"
    monitoring_security_group_id = "tmp"
  }
}

inputs = {
  vpc_id = local.vars.create_network ? dependency.network.outputs.vpc_id : local.vars.k8s_vpc_id
  subnets = local.vars.create_network ? dependency.network.outputs.public_subnets : local.vars.k8s_subnets
  security_group_id = local.vars.create_network ? dependency.network.outputs.k8s_security_group_id : local.vars.k8s_security_group_id

  worker_additional_security_group_ids = local.vars.create_network ? [
    dependency.network.outputs.consul_security_group_id, dependency.network.outputs.monitoring_security_group_id
  ] : local.vars.k8s_worker_additional_security_group_ids

  worker_groups = [
    {
      name                 = "workers"
      instance_type        = local.vars.worker_instance_type
      asg_desired_capacity = local.vars.num_workers
      asg_min_size         = local.vars.cluster_autoscale_min_workers
      asg_max_size         = local.vars.cluster_autoscale_max_workers
      tags = concat([{
        key                 = "Name"
        value               = "${local.id}-workers-1"
        propagate_at_launch = true
      }
      ])
    }
  ]
}
