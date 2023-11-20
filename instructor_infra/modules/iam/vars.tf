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

variable "account_id" {
  default = ""
}
variable "region" {
  default = "eu-west-1"
}

variable "environment" {}
variable "batch_job_queue" {}
variable "vpc_id" {}
