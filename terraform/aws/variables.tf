variable "project_name" { type = string }
variable "environment" { type = string }
variable "owner" { type = string }

variable "aws_region" { type = string }

variable "vpc_cidr" { type = string }

variable "public_subnet_cidr" { type = string }
variable "private_app_subnet_cidr" { type = string }
variable "private_db_subnet_cidr" { type = string }

variable "aws_az_public" { type = string }
variable "aws_az_private_app" { type = string }
variable "aws_az_private_db" { type = string }