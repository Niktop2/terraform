resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.name}-vpc"
    Env  = "ops"
  }
}

resource "aws_subnet" "private-subnet-a" {
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.az1
  vpc_id            = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.name}-private-subnet-a"
    Env  = "ops"
  }
}

resource "aws_subnet" "private-subnet-b" {
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.az2
  vpc_id            = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.name}-private-subnet-b"
    Env  = "ops"
  }
}
resource "aws_subnet" "public-subnet-a" {
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.az1
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-subnet-a"
    Env  = "ops"
  }
}
resource "aws_subnet" "public-subnet-b" {
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.az2
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-subnet-b"
    Env  = "ops"
  }
}


# resource "aws_s3_bucket" "my-s3" {
#  bucket = "studentapp-ops-tfstate"
#  tags = {
#    Name= "${var.name}-bucket"
#    Env = "ops"
#  }  
# }

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.name}-igw"
    Env = "ops"
  }
  
}

resource "aws_default_route_table" "my-rt" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.my-igw.id  
  }
}

