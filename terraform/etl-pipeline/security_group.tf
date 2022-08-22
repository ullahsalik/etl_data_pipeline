####################################################################################
####                                                                            ####
####                  US East (N. Virginia) Region  (us-east-1)                 ####
####                                                                            ####
####################################################################################

module "security_group_Port_all_excpet_22_Private_CIDR" {
  source       = "../terraform-modules/security_group"
  product_name = var.product_name
  name         = "Port_all_excpet_22_Private_CIDR"
  env          = var.env
  tags = {
    "Name"    = "Port_all_excpet_22_Private_CIDR"
    "Creator" = "terraform"
  }
  vpc_id = data.terraform_remote_state.base_networking_infra_remote_state.outputs.vpc_id_us_east_1

  ingress_rules = [
    {
      from_port   = 0
      to_port     = 21
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["10.80.0.0/16"]
      description = "Port_0_21_all_Private_CIDR"
    },
    {
      from_port   = 23
      to_port     = 65535
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["10.80.0.0/16"]
      description = "Port_23_65535_all_Private_CIDR"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      type        = "egress"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic"
    }
  ]
}

module "security_group_Port_22" {
  source       = "../terraform-modules/security_group"
  product_name = var.product_name
  name         = "Port-22-Only"
  env          = var.env
  tags = {
    "Name"    = "Port-22-Only"
    "Creator" = "terraform"
  }
  vpc_id = data.terraform_remote_state.base_networking_infra_remote_state.outputs.vpc_id_us_east_1

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

      description = "Allow trafic to port 22"
    },
    {
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

      description = "Allow trafic to port 22"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      type        = "egress"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all trafic"
    }
  ]
}

module "security_group_icmp_us_east_1" {
  source       = "../terraform-modules/security_group"
  product_name = var.product_name
  name         = "Port-ICMP-allow"
  env          = var.env
  tags = {
    "Name"    = "Port-ICMP-allow"
    "Creator" = "terraform"
  }
  vpc_id = data.terraform_remote_state.base_networking_infra_remote_state.outputs.vpc_id_us_east_1

  ingress_rules = [
    {
      from_port   = 8
      to_port     = 0
      type        = "ingress"
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ping"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      type        = "egress"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic"
    }
  ]
}