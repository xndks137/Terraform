data "aws_ami" "myubuntu2404" {
  most_recent = true
  owners = ["099720109477"] 
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.myubuntu2404.id
  instance_type = var.instance_type
  tags = var.ec2_tag
  user_data = file("${path.module}/userdata.sh")
  user_data_replace_on_change = true

  # 필수 입력 사항
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = var.sg_ids
  key_name = var.keypair
}