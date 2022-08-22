
####################################################################################
####                                                                            ####
####                                                                            ####
####                      Secret Manager ReportPortal                           ####
####                                                                            ####
####                                                                            ####
####################################################################################
module "rds_secret_manager" {
  source            = "../terraform-modules/secret_manager"
  product_name      = var.product_name
  env               = var.env
  name              = "rds-secrets"
  tags              = local.global_tags
}
