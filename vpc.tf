
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "cluster-${var.project_name}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "./vpc-module"

  name                 = "vpc-${var.environment}-${var.project_name}"
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.8.0/26", "172.16.8.64/26", "172.16.8.128/26"]
  public_subnets       = ["172.16.8.192/26", "172.16.9.0/26", "172.16.9.64/26"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    Project     = var.project_name
    Environment = var.environment
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    Project     = var.project_name
    Environment = var.environment
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    Project     = var.project_name
    Environment = var.environment
  }
}

