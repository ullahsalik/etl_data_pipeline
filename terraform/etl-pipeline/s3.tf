module "s3_etl_batch_files_data" {
    source            = "../terraform-modules/s3"
    product_name      = var.product_name
    env               = var.env
    name              = "batch-files"
    acl               = "private"
    enable_versioning = false
    tags              = local.global_tags
}