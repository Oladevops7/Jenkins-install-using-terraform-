terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow 8080 & 22 inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alloww tls"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  subnet_id = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  key_name = "jenkins" #Complete by creating your own key name

  tags = {
    name = "Jenkins Server"
  }

}

resource "null_resource" "name" {

    #SSH into ec2 instance

 connection {
   type = "ssh"
   user = "ubuntu"
   private_key = file("/Users/user1/Downloads/jenkins.pem")
   host = aws_instance.jenkins_server.public_ip
   
 }

 # copy the install_jenkins.sh file from local to ec2
 provisioner "file" {
    source = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
   
 }
  #Set permission and execute the install_jenkins.sh file
 provisioner "remote-exec" {
   inline = [ 
        "sudo chmod +x /tmp/install_jenkins.sh",
        "sh /tmp/install_jenkins.sh"
    ]
}

depends_on = [
    aws_instance.jenkins_server
]
}