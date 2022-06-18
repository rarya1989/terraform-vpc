provider "aws" {
   region = "ap-southeast-1"
 }

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "jenkins_ssh" {
  name = "jenkins"
  vpc_id = aws_vpc.Main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = [aws_vpc.Main.cidr_block]
  }

   ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_ssh" {
  name = "web"
  vpc_id = aws_vpc.Main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = [aws_vpc.Main.cidr_block]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_vpc" "Main" {                
   cidr_block       = var.main_vpc_cidr     
   instance_tenancy = "default"
 }

resource "aws_internet_gateway" "IGW" {    
   vpc_id =  aws_vpc.Main.id               
 }

resource "aws_subnet" "publicsubnets" {    
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.public_subnets}"        
 }
               
resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.private_subnets}"          
 }

resource "aws_route_table" "PublicRT" {    
   vpc_id =  aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"               
   gateway_id = aws_internet_gateway.IGW.id
   }
 }

resource "aws_route_table" "PrivateRT" {    
   vpc_id = aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"             
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }

resource "aws_route_table_association" "PublicRTassociation" {
   subnet_id = aws_subnet.publicsubnets.id
   route_table_id = aws_route_table.PublicRT.id
 }

resource "aws_route_table_association" "PrivateRTassociation" {
   subnet_id = aws_subnet.privatesubnets.id
   route_table_id = aws_route_table.PrivateRT.id
 }

resource "aws_eip" "nateIP" {
   vpc   = true
 }

resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.publicsubnets.id
  key_name        = "equal"
  associate_public_ip_address = true
  security_groups = [aws_security_group.jenkins_ssh.id]
  user_data = "${file("user-data.sh")}"
  
  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}

resource "aws_instance" "test-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.privatesubnets.id
  key_name        = "equal"
  security_groups = [aws_security_group.web_ssh.id]
  
  tags = {
    "Name"      = "web_Server"
    "Terraform" = "true"
  }
}
