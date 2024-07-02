terraform {
  backend "remote" {
    organization = "hyungwook"

    workspaces {
      name = "default"
    }
  }
}

provider "aws" {
  region = var.region
}