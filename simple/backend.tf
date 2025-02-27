terraform {
  backend "s3" {
    bucket = "samplebucketterra010"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
