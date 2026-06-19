terraform {
  required_version = ">= 1.5.0"

  required_providers {
    pingfederate = {
      source  = "pingidentity/pingfederate"
      version = "~> 1.0"
    }
  }

  # Uncomment and configure for remote state (S3, Terraform Cloud, etc.)
  # backend "s3" {
  #   bucket = "your-tfstate-bucket"
  #   key    = "pingfederate/terraform.tfstate"
  #   region = "us-east-1"
  # }
}
