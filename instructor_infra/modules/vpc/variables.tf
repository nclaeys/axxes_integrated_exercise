variable "environment" {
  description = "The name of the environment."
}

variable "vpc_cidr" {
  description = "The cidr of to vpc to create."
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "The availability zones to use."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "The public subnet cidrs of to vpc to create."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "The private subnets cidr of to vpc to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  default     = {}
  description = "Tags to assign to all resources"
  type        = map(string)
}
