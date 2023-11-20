resource "aws_ssm_parameter" "s3_bucket" {
  name = "/${local.env_name}/s3_bucket"
  type = "String"
  value = "dataminded-academy-capstone-resources"
}

resource "aws_ssm_parameter" "vpc_id" {
  name = "/${local.env_name}/vpc_id"
  type = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "subnet_ids" {
  name = "/${local.env_name}/subnet_ids"
  type = "StringList"
  value = join(",",module.vpc.private_subnet_ids)
}

resource "aws_ssm_parameter" "mwaa_role_arn" {
  name = "/${local.env_name}/mwaa_role_arn"
  type = "String"
  value = module.iam.mwaa_role_arn
}

resource "aws_ssm_parameter" "batch_job_role_arn" {
  name = "/${local.env_name}/batch_job_role_arn"
  type = "String"
  value = module.iam.batch_job_role_arn
}

resource "aws_ssm_parameter" "mwaa_sg_id" {
  name = "/${local.env_name}/mwaa_sg_id"
  type = "String"
  value = module.mwaa.mwaa_sg_id
}