module "rds_subnet_group" {
    source                                = "../terraform-modules/db_subnet_group"
    name                                  = "rds-subnet-group"
    product_name                          = var.product_name
    env                                   = var.env
    public_restricted_subnet_a            = "${data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_a_us_east_1}"
    public_restricted_subnet_b            = "${data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_b_us_east_1}"
    public_restricted_subnet_c            = "${data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_c_us_east_1}"
    tags                                  = local.global_tags
}