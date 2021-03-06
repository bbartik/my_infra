data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.base_tag}-VPC"
    public = "true"
  }
}

resource "aws_subnet" "public" {
  count                   = var.number_of_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.base_tag}-public-${data.aws_availability_zones.this.names[count.index]}"
    public = "true"
  }
}

resource "aws_subnet" "private" {
  count                   = var.number_of_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index + var.number_of_subnets)
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.base_tag}-private-${data.aws_availability_zones.this.names[count.index]}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.base_tag}-IGW"
  }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
    Name = "${var.base_tag}-Public"
    }
}

data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    public = "true"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
    for_each = data.aws_subnet_ids.public.ids
    subnet_id = each.value
    route_table_id = aws_route_table.public.id
}