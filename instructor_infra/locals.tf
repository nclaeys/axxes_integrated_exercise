locals {
  env_name = "integrated-exercise"
  account_id = "299641483789"
  region = "eu-west-1"
  participants_permissions = yamldecode(file("${path.root}/participants-access.yaml"))
}