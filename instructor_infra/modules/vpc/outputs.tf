output "env_name" {
  value = var.environment
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "az" {
  value = var.azs
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnet_cidrs" {
  value = var.public_subnet_cidrs
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnet_cidrs" {
  value = var.private_subnet_cidrs
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}
