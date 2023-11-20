variable "env_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "allowed_cidrs" {
  type = list(string)
}
variable "account_id" {}