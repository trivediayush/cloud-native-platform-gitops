terraform {
  backend "s3" {
    bucket       = "cloud-native-platform-tfstate"
    key          = "terraform/platform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}