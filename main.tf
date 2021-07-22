# #DATA
#to get latest AMI
data "aws_ssm_parameter" "windows" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base"
}

#to get current accountID
data "aws_caller_identity" "current" {}

#PROVIDER
provider "aws" {
  region                  = var.region
  # shared_credentials_file = "C:\\terraform\\DM\\credentials"
  # profile                 = "admin"
  access_key = "my-access-key"
  secret_key = "my-secret-key"  
}

#VPC
module "vpc" {
  source                             = "terraform-aws-modules/vpc/aws"
  name                               = "cummin-uat-vpc"
  cidr                               = "192.168.0.0/16"
  azs                                = var.availability_zones
  enable_dns_hostnames               = true
  enable_dns_support                 = true
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  public_subnets                     = var.subnet_cidrs_public
  database_subnets                   = var.subnet_cidrs_rds
  private_subnets                    = var.subnet_cidrs_ecs
  propagate_public_route_tables_vgw  = true
  propagate_private_route_tables_vgw = true
  public_subnet_tags = {
    Name = "itrams-dm-platform-uat-dmz-sn"
  }
  private_subnet_tags = {
    Name = "itrams-dm-platform-uat-ecs-sn"
  }
  database_subnet_tags = {
    Name = "itrams-dm-platform-uat-rds-sn"
  }
  database_route_table_tags = {
    Name = "itrams-dm-platform-private-rds-rtb"
  }
  private_route_table_tags = {
    Name = "itrams-dm-platform-private-ecs-rtb"
  }
  public_route_table_tags = {
    Name = "itrams-dm-platform-public-subnet-rtb"
  }
}

#EIP for NAT gw
resource "aws_eip" "nat" {
  vpc = "true"
}

#SG
resource "aws_security_group" "bas" {
  name   = "itrams-dm-prod-bas-sg-01"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = ingress.value["cidr_blocks"]
      ipv6_cidr_blocks = ingress.value["ipv6_cidr_blocks"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name   = "itrams-dm-platform-rds-db-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bas.id}", "${aws_security_group.ecs.id}"]
    description     = "Access from RDS and Bastion host"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssm" {
  name   = "sg_ssm"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs.id}", "${aws_security_group.bas.id}"]
    description     = "Access from ALB"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "itrams-dm-prod-ecs-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
    description     = "Access from ALB"
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
    description     = "Access from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name   = "itrams-dm-platform-prod-alb-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}