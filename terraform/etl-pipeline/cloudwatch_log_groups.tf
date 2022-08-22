####################################################################################
####                                                                            ####
####                                                                            ####
####               Cloudwatch Logs for App                         ####
####                                                                            ####
####                                                                            ####
####################################################################################

 module "cloudwatch_log_group" {  
   source     = "../terraform-modules/cloudwatch_log_groups"
   group_name = "transformation/${var.product_name}/${var.env}"
   tags       = local.global_tags
 }