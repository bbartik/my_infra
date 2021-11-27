variable "cidr_block" {
    description = "CIDR block for this VPC, use a /16"
}

variable "number_of_subnets" {
    description = "Number of subnets desired in this VPC"
    default = "2"
}

variable "base_tag" {
    description = "Base tag used for naming"
}