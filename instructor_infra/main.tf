module "iam" {
  source                   = "./modules/iam"
  participants_permissions = local.participants_permissions
  account_id               = local.account_id
  environment              = local.env_name
  batch_job_queue          = module.batch.job_queue
  vpc_id                   = module.vpc.vpc_id
  depends_on = [ aws_s3_bucket.integrated-exercise ]
}

#module "snowflake" {
#  source      = "../../modules/snowflake"
#  group       = local.participants_permissions.group
#  secret_name = local.participants_permissions.secret_access.secret
#}

module "batch" {
  source             = "./modules/batch"
  account_id         = local.account_id
  env_name           = local.env_name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  allowed_cidrs = [
    module.vpc.vpc_cidr_block
  ]
  depends_on = [ aws_s3_bucket.integrated-exercise ]
}

module "vpc" {
  source      = "./modules/vpc"
  environment = local.env_name
  vpc_cidr    = "10.1.0.0/16"
  azs = [
    "eu-west-1c",
    "eu-west-1a"
  ]
  private_subnet_cidrs = [
    "10.1.3.0/24",
    "10.1.4.0/24"
  ]
  public_subnet_cidrs = [
    "10.1.103.0/24",
    "10.1.104.0/24"
  ]
}


module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
    },
  }
}

module "mwaa" {
  source                   = "./modules/mwaa"
  environment              = local.env_name
  vpc_id                   = module.vpc.vpc_id
  mwaa_role_arn            = module.iam.mwaa_role_arn
  subnet_ids               = join(",", module.vpc.private_subnet_ids)
  participants_permissions = local.participants_permissions
  depends_on = [ aws_s3_bucket.integrated-exercise ]
}