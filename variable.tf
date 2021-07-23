variable "region" {
  default = "us-east-1"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
  type        = list(string)
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
  type        = list(string)
}

variable "subnet_cidrs_rds" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24", "192.168.14.0/24"]
  type        = list(string)
}

variable "subnet_cidrs_ecs" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["192.168.21.0/24", "192.168.22.0/24", "192.168.23.0/24", "192.168.24.0/24"]
  type        = list(string)
}

variable "rules" {
  default = [
    {
      port             = 22
      protocol         = "tcp"
      cidr_blocks      = ["45.112.36.0/22", "118.69.72.213/32", "27.74.249.82/32", "123.63.55.53/32", "14.143.28.3/32", "103.4.124.0/22"]
      ipv6_cidr_blocks = ["2401:d00::/32"]
    },
    {
      port             = 3389
      protocol         = "tcp"
      cidr_blocks      = ["45.112.36.0/22", "103.4.124.0/22", "118.69.72.213/32", "27.74.249.82/32", "123.63.55.53/32", "14.143.28.3/32"]
      ipv6_cidr_blocks = ["2401:d00::/32"]
    }
  ]
}