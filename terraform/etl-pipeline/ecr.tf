# ECR for Services
####################################################################################
####                                                                            ####
####                                    ECR Repo                                ####
####                                                                            ####
####################################################################################
module "ecr_guac" {
    source                      = "../terraform-modules/ecr_repository"
    name                        = "transformation-app"
    product_name                = local.product_name
    env                         = local.env
    image_tag_mutability        = "MUTABLE"
    scan_on_push                = "true"
    encryption_type             = "KMS"
    tags                        = local.global_tags   
}