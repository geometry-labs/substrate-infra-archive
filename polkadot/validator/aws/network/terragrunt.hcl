terraform {
  source = "github.com/insight-w3f/terraform-polkadot-aws-network.git?ref=${local.vars.versions.network}"
}

skip = !local.vars.create_network

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl")).locals.run
}

inputs = {
  vpc_name = local.vars.versions.network
}
