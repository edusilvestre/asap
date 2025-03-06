terraform {
  backend "s3" {
    bucket  = "eduardo-teste-asap"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
