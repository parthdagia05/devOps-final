variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to spread workloads"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "db_name" {
  description = "PostgreSQL Database Name"
  type        = string
  default     = "orderdb"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "orderuser"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}
