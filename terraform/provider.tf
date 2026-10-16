provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "OrderSystem"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
