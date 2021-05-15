provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "${var.cidr1_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc1"
  }
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = "${aws_vpc.vpc1.id}"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "subnet1_public" {
  vpc_id = "${aws_vpc.vpc1.id}"
  cidr_block = "${var.cidr1_subnet}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_route_table" "rtb1_public" {
  vpc_id = "${aws_vpc.vpc1.id}"
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw1.id}"
  }
  tags = {
    Name = "vpc1"
  }
}

resource "aws_route_table_association" "rta_subnet1_public" {
  subnet_id      = "${aws_subnet.subnet1_public.id}"
  route_table_id = "${aws_route_table.rtb1_public.id}"
}

resource "aws_security_group" "ssh_from_home1" {
  name = "ssh_from_home"
  vpc_id = "${aws_vpc.vpc1.id}"
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["208.76.0.0/22"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh_from_home1"
  }
}

resource "aws_instance" "test1" {
  ami           = "${data.aws_ami.amazonlinux2.id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet1_public.id}"
  vpc_security_group_ids = ["${aws_security_group.ssh_from_home1.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2_ssm_cwa.name}"
  key_name = "csmithaws"
  tags = {
    Name = "vpc1"
    ssm = "true"
  }
}

resource "aws_iam_instance_profile" "ec2_ssm_cwa" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

resource "aws_iam_role" "test_role" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-cwa-policy" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-ssm-policy" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
