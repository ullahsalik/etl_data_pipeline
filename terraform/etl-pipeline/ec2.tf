locals {
  public_subnets              = [data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_public_all_access_subnet_a_us_east_1, data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_public_all_access_subnet_b_us_east_1, data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_public_all_access_subnet_c_us_east_1]
  private_subnets             = [data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_a_us_east_1, data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_b_us_east_1, data.terraform_remote_state.base_networking_infra_remote_state.outputs.common_private_subnet_c_us_east_1]
}

module "common_bastion" {
  source                      = "../terraform-modules/ec2"
  name                        = "bastion"
  product_name                = var.product_name
  env                         = var.env
  tags                        = local.global_tags
  subnet_id                   = local.public_subnets[0]
  availability_zone           = "${var.region}a"
  vpc_security_group_ids      = [module.security_group_Port_22.security_group_id]
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t3a.xlarge"
  iam_instance_profile        = module.rds_auth_instance_profile.instance_profile_name
  key_name                    = "test-assignment-2"
  associate_public_ip_address = "true"
  delete_on_termination       = "true"
  iops                        = 3000
  volume_size                 = 8
  volume_type                 = "gp3"
  user_data_path              = null
}