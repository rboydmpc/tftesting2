terraform {
   required_version = ">= 0.12.31"

#   required_providers {
#     aws = ">= 4.0.0"
#   }
}

provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
  }

variable "access_key" {}
variable "secret_key" {}
variable "region" {
   default = "us-east-1"
}
variable "mytag" {
}

# Creating Amazon EFS File system
resource "aws_efs_file_system" "myfilesystem" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = var.mytag
  }
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.myfilesystem.id
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.myfilesystem.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.myfilesystem.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}
