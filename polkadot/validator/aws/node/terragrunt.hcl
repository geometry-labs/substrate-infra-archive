terraform {
  source = "github.com/insight-w3f/terraform-polkadot-aws-node.git?ref=${local.vars.versions.node}"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.run
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
    validator_subnet_ids = ["tmp"]
    validator_security_group_id = "tmp"
  }
}

inputs = {
  node_purpose = "validator"
  security_groups = local.vars.create_network ? [
    dependency.network.outputs.validator_security_group_id,
  ] : local.vars.validator_security_groups
  subnet_ids = local.vars.create_network ? dependency.network.outputs.public_subnets : local.vars.validator_subnet_ids
  vpc_id = local.vars.create_network ? dependency.network.outputs.vpc_id : local.vars.validator_vpc_id
  project = local.vars.name
}
