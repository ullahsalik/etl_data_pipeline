module "rds_auth_instance_profile" {
    source          = "../terraform-modules/ec2_instance_profile"
    product_name    = var.product_name
    env             = var.env
    name            = "rds-authenticate-profile"
    role_name       = module.rds_auth_iam_role.role_name
}