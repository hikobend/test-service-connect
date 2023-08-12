# バージョン情報
terraform {
  required_version = "1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# プロバイダー情報
provider "aws" {
  region = "ap-northeast-1"
}
