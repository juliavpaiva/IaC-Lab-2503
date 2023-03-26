terraform {
  backend "s3" {
    bucket = "terraform-state-files-julia-mack"
    key = "state-file"
    region = "eu-west-1"
  }
}
provider "aws" {
    region = "eu-west-1"
}