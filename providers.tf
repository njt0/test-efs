terraform {
  cloud {

    organization = "myawstest"

    workspaces {
      name = "efstest"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
