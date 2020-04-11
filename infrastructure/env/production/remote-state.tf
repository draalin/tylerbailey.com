terraform {
  backend "s3" {
    bucket         = "tylerbailey-terraform-state"
    encrypt        = true
    dynamodb_table = "tylerbailey-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
