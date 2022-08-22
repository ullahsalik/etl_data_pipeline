module "blue-green" {
    source       = "../terraform-modules/blue_green"
    product_name = var.product_name
    env          = var.env
    name         = "aurora-postgresql"
    tags         = local.global_tags
}

###########################################################################################################
###                                 RDS CLUSTER
###########################################################################################################

resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier          = lower("${module.blue-green.id}")
    deletion_protection         = false
    skip_final_snapshot         = false
    allow_major_version_upgrade = false
    final_snapshot_identifier   = ("${local.env}-${local.product_name}-final-db-snap")
    engine                      = "aurora-postgresql"
    engine_mode                 = "provisioned"
    engine_version              = "13.6"
    storage_encrypted           = true
    port                        = "5432"
    database_name               = "test_db"
    master_username             = "root"
    master_password             = random_password.dbpassword.result
    vpc_security_group_ids      = [module.security_group_Port_all_excpet_22_Private_CIDR.security_group_id]
    db_subnet_group_name        = module.rds_subnet_group.subnet_group_id
    backup_retention_period     = 7
    iam_database_authentication_enabled = true
    tags                        = merge(local.global_tags, { "Name" : lower("${module.blue-green.id}") })
    serverlessv2_scaling_configuration {
        max_capacity            = 1.0
        min_capacity            = 0.5
    }
}

resource "aws_rds_cluster_instance" "rds_instance" {
    cluster_identifier          = aws_rds_cluster.db_cluster.id
    instance_class              = "db.serverless"
    engine                      = aws_rds_cluster.db_cluster.engine
    engine_version              = aws_rds_cluster.db_cluster.engine_version
}