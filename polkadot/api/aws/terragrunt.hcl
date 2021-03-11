locals {
  run = yamldecode(file(find_in_parent_folders("run.yml"))) # input
  settings = yamldecode(file(find_in_parent_folders("settings.yml")))
  id = join("-", [ for i in local.settings.id_label_order : lookup(local.run, i)])
  name = join("", [ for i in local.settings.name_label_order : title(lookup(local.run, i))])
  tags = { for t in local.settings.remote_state_path_label_order : t => lookup(local.run, t) }
  remote_state_path = join("/", [ for i in local.settings.remote_state_path_label_order : lookup(local.run, i)])
}

inputs = merge(
local,
local.run,
)

generate "provider" {
  path = "tg-provider.tf"
  if_exists = "skip"
  contents =<<-EOF
provider "aws" {
  region = "${local.run.region}"
  skip_get_ec2_platforms     = true
  skip_metadata_api_check    = true
  skip_region_validation     = true
  skip_requesting_account_id = true


  dynamic "assume_role" {
    for_each = ${local.run.use_assume_role} ? [1] : []
    content {
      role_arn = "arn:aws:iam::${lookup(local.run, "account_id", get_aws_account_id())}:role/${lookup(local.run, "role_name", "Administrator")}"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    region = "us-east-1"
    key = "${local.remote_state_path}/${path_relative_to_include()}/terraform.tfstate"
    bucket = "terraform-states-${get_aws_account_id()}"
    dynamodb_table = "terraform-locks-${get_aws_account_id()}"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
