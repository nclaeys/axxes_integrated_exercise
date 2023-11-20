variable "environment" {}
variable "vpc_id" {}
variable "mwaa_role_arn" {}
variable "subnet_ids" {}
variable "participants_permissions" {
  type = object({
    group = string
    s3_access = object({
      bucket = string
      dags_folder = string
    })
    secret_access = object({
      secret = string
    })
  })
}