terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  # Налаштування бекенду з вашими даними
  backend "s3" {
    bucket         = "lab6-terraform-gulchak"  # <-- Ваш бакет
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"         # <-- Ваша таблиця
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "stack-orders-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_security_group" "web_sg" {
  name        = "flask-stack-sg"
  description = "Allow HTTP 5000 and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_stack_app_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_stack_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "app_server" {
  ami           = "ami-0a261c0e5f51090b1" # Amazon Linux 2023 (eu-central-1)
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker
              systemctl start docker
              systemctl enable docker

              sleep 10
              
              aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url}
              docker pull ${aws_ecr_repository.app_repo.repository_url}:latest
              docker run -d -p 5000:5000 ${aws_ecr_repository.app_repo.repository_url}:latest
              EOF

  tags = {
    Name = "Stack-Order-App"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "ecr_url" {
  value = aws_ecr_repository.app_repo.repository_url
}