terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "laba-6-7-daria"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "lab-my-tf-lockid"
  }
}
provider "aws" {
  region = "eu-central-1"
}
variable "REPOSITORY_URI" {
  type = string
}
resource "aws_lightsail_container_service" "flask_app" {
  name  = "flask-app-service"
  power = "nano"
  scale = 1
  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }
}
resource "aws_lightsail_container_service_deployment_version" "flask_deploy" {
  container {
    container_name = "flask-container"
    image          = "${var.REPOSITORY_URI}:latest"
    ports = {
      5000 = "HTTP"
    }
  }
  public_endpoint {
    container_name = "flask-container"
    container_port = 5000
    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200-499"
    }
  }
  service_name = aws_lightsail_container_service.flask_app.name
}
output "url" {
  value = aws_lightsail_container_service.flask_app.url
}