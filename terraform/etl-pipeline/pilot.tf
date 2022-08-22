provider "aws" {
    region                  = var.region
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "terraform-assignment"
}

terraform {
    backend "local" {
        path                    = "etl_pipeline_terraform.tfstate"
    } 
}

data "terraform_remote_state" "base_networking_infra_remote_state" {
  backend = "local"
    config = {
        path                    = "../base-networking/terraform.tfstate"
    }
}