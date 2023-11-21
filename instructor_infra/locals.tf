locals {
  env_name = "integrated-exercise"
  account_id = "167698347898"
  region = "eu-west-1"
  participants_permissions = yamldecode(file("${path.root}/participants-access.yaml"))
}