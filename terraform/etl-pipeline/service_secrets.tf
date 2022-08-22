module "sm_secret_values" {
    source              = "../terraform-modules/secret_manager_secrets"
    secret_manager_id   = module.rds_secret_manager.secret_id
    secret_strings      = <<EOF
                        {
                                "password": "${random_password.dbpassword.result}"
                        }
                        EOF
}