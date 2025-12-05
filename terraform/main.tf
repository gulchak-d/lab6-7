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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "web_sg" {
  name        = "flask-security-group"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" 
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3-pip
              pip3 install flask
              
              echo "from flask import Flask" > /home/ubuntu/app.py
              echo "app = Flask(__name__)" >> /home/ubuntu/app.py
              echo "@app.route('/')" >> /home/ubuntu/app.py
              echo "def hello(): return '<h1> Lab 6-7 completed </h1>'" >> /home/ubuntu/app.py
              echo "if __name__ == '__main__': app.run(host='0.0.0.0', port=5000)" >> /home/ubuntu/app.py
              
              nohup python3 /home/ubuntu/app.py &
              EOF

  tags = {
    Name = "Lab6-7-EC2"
  }
}

output "public_ip" {
  value = "http://${aws_instance.app_server.public_ip}:5000"
}