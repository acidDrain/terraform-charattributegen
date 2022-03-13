terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "elasticplayground"
    workspaces {
      name = "terraform-charattributegen"
    }
  }
}
