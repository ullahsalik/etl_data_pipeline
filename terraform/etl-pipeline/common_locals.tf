# common_locals.tf
locals {
  product_name = var.product_name
  env          = var.env
  global_tags  = {
    Environment = local.env
    Product     = local.product_name
    Terraform   = true
  }
}