terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "mojaloop"
  region  = "eu-west-2"
  default_tags {
    tags = {
      Environment = "oss-lab"
      Name        = "mini-loop"
    }
  }
}

resource "aws_instance" "mini-loop" {
  ami           = var.ami-map[var.linux-distro]
  instance_type = var.ml-instance-type 
  key_name      = var.ml-keyname

  root_block_device {
      volume_type = "gp3"
      volume_size = 100
  }


  tags = {
    "mojaloop/cost_center" =  "oss-lab" 
    "mojaloop/owner" = "tdaly"
  }
}
