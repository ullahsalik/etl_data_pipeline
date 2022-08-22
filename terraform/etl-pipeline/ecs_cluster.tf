module "ecs_cluster" {
    source                  = "../terraform-modules/ecs_cluster"
    name                    = "transformation-app"
    product_name            = var.product_name
    env                     = var.env
}