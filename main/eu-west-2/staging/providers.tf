terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }


  #   backend "s3" {
  #     bucket = "ter-amh-backend"
  #     key = "enviroments/staging/terraform.tfstate"
  #   }

}