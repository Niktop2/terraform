resource "aws_vpc" "my-vpc"{
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.name}-vpc"
    Env = "ops"
  }
}

resource "aws_subnet" "private-subnet-a"{
  cidr_block = var.private_subnet_a_cidr 
  availability_zone = var.az1
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.name}-private-subnet-a"
    Env = "ops"
  }
}

resource "aws_subnet" "private-subnet-b"{
  cidr_block = var.private_subnet_b_cidr 
  availability_zone = var.az2
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.name}-private-subnet-b"
    Env = "ops"
  }
}
resource "aws_subnet" "public-subnet-a"{
  cidr_block = var.public_subnet_a_cidr 
  availability_zone = var.az1
  vpc_id = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-subnet-a"
    Env = "ops"
  }
}
resource "aws_subnet" "public-subnet-b"{
  cidr_block = var.public_subnet_b_cidr 
  availability_zone = var.az1
  vpc_id = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-subnet-b"
    Env = "ops"
  }
}



