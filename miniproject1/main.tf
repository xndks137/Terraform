# 0. provier 설정 - provider.tf
#################################
# 기본 인프라 구성                
#################################
# 1. VPC 설정
# 2. Public subnet 설정
# 3. Internet Gateway 설정
# 4. Public Routing 설정
# 5. Public Routing Table Association(Public subnet <-> Public Routing) 설정
##################################
# EC2 인스턴스 생성 
##################################
# 1. Public Security Group 설정
# 2. AMI Data Source 설정
# 3. SSH Key 생성
# 4. EC2 Instance 생성


#### 기본 인프라 구성 ####
# 1. VPC 설정
resource "aws_vpc" "vpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "myVPC"
  }
}

# 2. Public subnet 설정
# * map_public_ip_on_launch = true
resource "aws_subnet" "public_SN" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.123.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "myPubSN"
  }
}

# 3. Internet Gateway 설정
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "myIGW"
  }
}

# 4. Public Routing 설정
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "myRT"
  }
}

# 5. Public Routing Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_SN.id
  route_table_id = aws_route_table.public_RT.id
}

#### EC2 인스턴스 생성 ####
# 1. Public Security Group 설정
resource "aws_security_group" "public_SG" {
  name        = "mySG"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.public_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2. SSH Key 생성
# resource "tls_private_key" "test_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "aws_key_pair" "test_keypair" {
  key_name   = "mykeypair3"
  public_key = file("~/.ssh/id_ed25519.pub")
} 

# 3. AMI Data Source 설정
data "aws_ami" "ubuntu2404" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 4. EC2 Instance 생성
resource "aws_instance" "devEC2" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.test_keypair.key_name
  subnet_id = aws_subnet.public_SN.id
  vpc_security_group_ids = [aws_security_group.public_SG.id]

  user_data_replace_on_change = true
  user_data = file("userdata.tpl")
  
  provisioner "local-exec" {
    command = templatefile("sshconfig.tpl",{
      hostname = self.public_ip,
      username = "ubuntu",
      identifyfile = "~/.ssh/id_ed25519"
      })
    interpreter = ["bash","-c"]
  }

  tags = {
    Name = "myDevServer"
  }
}

# Data Block
