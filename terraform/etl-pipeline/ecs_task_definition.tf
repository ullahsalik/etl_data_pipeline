data "aws_region" "current" {}
module "ecs_task_definition" {
    source                          = "../terraform-modules/ecs_task_definition"
    name                            = "transformation"
    product_name                    = var.product_name
    env                             = var.env
    family                          = "transformation-task"
    # container_definitions         = ""
    requires_compatibilities        = ["FARGATE"]
    network_mode                    = "awsvpc"
    memory                          = "512"
    cpu                             = "256"  
    execution_role_arn              = module.aws_iam_role_ecs_task_execution_role.role_arn
    task_role_arn                   = module.aws_iam_role_ecs_task_execution_role.role_arn
    image                           = "149767118118.dkr.ecr.us-east-1.amazonaws.com/transformation-app:latest"
    container_name                  = "transformation-app-container"
    port                            = 80
    log_group                       = module.cloudwatch_log_group.group_name
    region                          = "${data.aws_region.current.name}"
}