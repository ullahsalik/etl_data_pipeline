#####################################################################################
#####                                                                            ####
#####                                 IAM Policy                                 ####
#####                                                                            ####
#####################################################################################

data "aws_iam_policy_document" "iam_policy_for_rds" {
    statement {
        effect = "Allow"
        actions = [
            "rds-db:connect"
        ]
        resources = [
            "arn:aws:rds-db:${var.region}:149767118118:dbuser:dev-assignment-aurora-postgresql-v1/iamuser",
            "${aws_rds_cluster_instance.rds_instance.arn}"
        ]

    }
}

module "iam_policy_for_rds_auth" {
    source              = "../terraform-modules/iam_policy"
    name                = "assignment-policy"
    product_name        = var.product_name
    tags                = local.global_tags
    env                 = var.env
    iam_policy_doc_json = data.aws_iam_policy_document.iam_policy_for_rds.json
}

data "aws_iam_policy_document" "iam_policy_for_rds_all" {
    statement {
        effect = "Allow"
        actions = [
            "*"
        ]
        resources = [
            "*"
        ]
    }
}
module "iam_policy_for_rds" {
    source              = "../terraform-modules/iam_policy"
    name                = "rds"
    product_name        = var.product_name
    tags                = local.global_tags
    env                 = var.env
    iam_policy_doc_json = data.aws_iam_policy_document.iam_policy_for_rds_all.json
}

data "aws_iam_policy_document" "container_registry" {
    statement {
        effect = "Allow"
        actions = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
        ]
        resources = [
            "*"
        ]
    }
    
}

module "iam_policy_container_registry" {
    source              = "../terraform-modules/iam_policy"
    name                = "codebuild-container-registry"
    product_name         = var.product_name
    tags                = local.global_tags
    env                 = var.env
    iam_policy_doc_json = data.aws_iam_policy_document.container_registry.json
}

data "aws_iam_policy_document" "s3_data_bucket_policy" {
    statement {
        effect = "Allow"
        actions = [
            "s3:ListStorageLensConfigurations",
            "s3:ListAccessPointsForObjectLambda",
            "s3:GetAccessPoint",
            "s3:PutAccountPublicAccessBlock",
            "s3:GetAccountPublicAccessBlock",            
            "s3:ListAccessPoints",
            "s3:PutAccessPointPublicAccessBlock",
            "s3:ListJobs",
            "s3:PutStorageLensConfiguration",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
        ]
        resources = [
            "${module.s3_etl_batch_files_data.bucket_arn}",
            "${module.s3_etl_batch_files_data.bucket_arn}/*"
        ]
    }   
}

module "iam_policy_s3_bucket" {
    source              = "../terraform-modules/iam_policy"
    name                = "s3-data-bucket"
    product_name        = var.product_name
    tags                = local.global_tags
    env                 = var.env
    iam_policy_doc_json = data.aws_iam_policy_document.s3_data_bucket_policy.json
}

#####################################################################################
#####                                                                            ####
#####                                 IAM Role                                 ####
#####                                                                            ####
#####################################################################################

data "aws_iam_policy_document" "assume_ec2_role_policy" {
    statement {
        sid         = "assumePolicy"
        actions     = [
                        "sts:AssumeRole",
                    ]
        principals {
                        type        = "Service"
                        identifiers = ["ec2.amazonaws.com"]
                    }
        effect      = "Allow"
    }
}

module "rds_auth_iam_role" {
    source                = "../terraform-modules/iam_roles"
    product_name          = local.product_name
    env                   = local.env
    assume_role_policy    = data.aws_iam_policy_document.assume_ec2_role_policy.json
    name                  = "rds-authenticate-role"
    tags                  = local.global_tags
}

data "aws_iam_policy_document" "assume_role_policy_ecs_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

module "aws_iam_role_ecs_task_execution_role"{
  source             = "../terraform-modules/iam_roles"
  product_name       = var.product_name
  env                = var.env
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ecs_task_execution.json
  name               = "ecs-task-execution"
  tags               = local.global_tags
}

#####################################################################################
#####                                                                            ####
#####                       IAM Role & Policy Attachment                         ####
#####                                                                            ####
#####################################################################################


module "assignment_lambda_role_policy_attachment" {
    source                      = "../terraform-modules/iam_role_policy_attachments"
    role_name                   =  module.rds_auth_iam_role.role_name
    custom_role_policy_arns     = [ 
                                    module.iam_policy_for_rds_auth.arn,
                                ]
}

module "iam_role_policy_attachment_ecs_task_execution" {
  source                        = "../terraform-modules/iam_role_policy_attachments"
  role_name                     =  module.aws_iam_role_ecs_task_execution_role.role_name
  custom_role_policy_arns       = [
                                    module.iam_policy_container_registry.arn,
                                    module.iam_policy_s3_bucket.arn,
                                    module.iam_policy_for_rds_auth.arn,
                                    module.iam_policy_for_rds.arn,
                                    
                                ]
}