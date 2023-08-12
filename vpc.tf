module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  cidr                    = "10.0.0.0/16"
  azs                     = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_names     = ["public-subnet-1a", "public-subnet-1c"]
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = false

  vpc_tags                = { Name = "vpc" }
  public_route_table_tags = { Name = "route-table-public" }
  igw_tags                = { Name = "internet-gateway" }
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "security-group"
  description = "security-group"
  vpc_id      = module.network.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}
