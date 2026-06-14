project_name = "secure-multicloud-zero-trust"
environment  = "dev"
owner        = "kamil-mandi"

aws_region = "eu-west-3"

vpc_cidr = "10.10.0.0/16"

public_subnet_cidr      = "10.10.0.0/24"
private_app_subnet_cidr = "10.10.1.0/24"
private_db_subnet_cidr  = "10.10.2.0/24"

aws_az_public      = "eu-west-3a"
aws_az_private_app = "eu-west-3b"
aws_az_private_db  = "eu-west-3c"