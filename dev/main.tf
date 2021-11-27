terraform {
	backend "remote" {
		organization = "bbartik"
		workspaces {
			name = "my_infra_dev"
    }
  }
}

provider "aws" {
  region  = var.region
	access_key = var.aws_access_key_id
	secret_key = var.aws_secret_access_key

  default_tags {
    tags = {
      owner = "bbartik"
      environment = "dev"
      Terraform = "true"
      }
	}
}

module "my_vpc1" {
  source = "git::https://github.com/bbartik/my_infra.git//modules/vpc"

  cidr_block = "10.51.0.0/16"
  number_of_subnets = "2"
  base_tag = "BB-TF-Lab"
}

data "aws_subnet_ids" "public" {
  vpc_id = module.my_vpc1.aws_vpc.this.id

  tags = {
    public = "true"
  }
}

output "public_subnet_ids" {
  value = data.aws_subnet_ids.public
}