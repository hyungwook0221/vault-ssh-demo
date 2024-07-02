terraform {
  backend "remote" {
    organization = "hyungwook"

    workspaces {
      name = "vault-ssh-demo"
    }
  }
}

provider "aws" {
  region = var.region
}