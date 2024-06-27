provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "app_deploy_docker" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "App-Deploy-Docker"
  }
}

resource "aws_subnet" "docker_subnet_pub" {
  vpc_id            = aws_vpc.app_deploy_docker.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Docker-Subnet-Pub"
  }
}

resource "aws_subnet" "docker_subnet_pvt" {
  vpc_id            = aws_vpc.app_deploy_docker.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Docker-Subnet-Pvt"
  }
}

resource "aws_internet_gateway" "docker_igw" {
  vpc_id = aws_vpc.app_deploy_docker.id
  tags = {
    Name = "Docker IGW"
  }
}

resource "aws_route_table" "docker_rt_def" {
  vpc_id = aws_vpc.app_deploy_docker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker_igw.id
  }
  tags = {
    Name = "Docker-RT-def"
  }
}

resource "aws_route_table_association" "pub_subnet_assoc" {
  subnet_id      = aws_subnet.docker_subnet_pub.id
  route_table_id = aws_route_table.docker_rt_def.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "docker_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.docker_subnet_pub.id
  tags = {
    Name = "Docker NAT"
  }
}

resource "aws_route_table" "docker_rt_c" {
  vpc_id = aws_vpc.app_deploy_docker.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.docker_nat.id
  }
  tags = {
    Name = "Docker-RT-C"
  }
}

resource "aws_route_table_association" "pvt_subnet_assoc" {
  subnet_id      = aws_subnet.docker_subnet_pvt.id
  route_table_id = aws_route_table.docker_rt_c.id
}

resource "aws_security_group" "docker_sg" {
  vpc_id = aws_vpc.app_deploy_docker.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Docker-SG"
  }
}

resource "aws_instance" "docker_ec2_pub1" {
  ami           = "ami-04b70fa74e45c37"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet_pub.id
  key_name      = "venkat_key2"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  tags = {
    Name = "Docker-EC2-Pub"
  }
}

resource "aws_instance" "docker_ec2_pub2" {
  ami           = "ami-04b70fa74ec3917"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet_pub.id
  key_name      = "venkat_key2"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  tags = {
    Name = "Docker-EC2-Pub"
  }
}

resource "aws_instance" "docker_ec2_pvt" {
  ami           = "ami-04b70fa74ec3917"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet_pvt.id
  key_name      = "venkat_key2"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  tags = {
    Name = "Docker-EC2-Pvt"
  }
}

resource "aws_lb" "docker_alb" {
  name               = "Docker-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_sg.id]
  subnets            = [
    aws_subnet.docker_subnet_pub.id,
    aws_subnet.docker_subnet_pvt.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "Docker-ALB"
  }
}

resource "aws_lb_target_group" "docker_tg" {
  name        = "Docker-TAG"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_deploy_docker.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Docker-TAG"
  }
}

resource "aws_lb_listener" "docker_listener" {
  load_balancer_arn = aws_lb.docker_alb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker_tg.arn
  }
}
