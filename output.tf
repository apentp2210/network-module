output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ami_id" {
  value     = data.aws_ssm_parameter.windows.value
  sensitive = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet1" {
  value = element(module.vpc.public_subnets, 0)
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "bas_sg" {
  value = aws_security_group.bas.id
}

output "rds_subnets" {
  value = module.vpc.database_subnets
}

output "rds_sg" {
  value = aws_security_group.rds.id
}

output "alb_sg" {
  value = aws_security_group.alb.id
}