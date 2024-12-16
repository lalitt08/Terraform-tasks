provider "aws" {
    region = "us-east-2"
 }

resource "aws_vpc" "Myvpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name ="Myvpc"
    }
}

resource "aws_subnet" "Publicsubnet1"{
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = "us-east-2a"
    tags = {
        Name = "Publicsubnet"
    }
}

resource "aws_subnet" "Publicsubnet2"{
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = var.public_subnet2_cidr
    availability_zone = "us-east-2c"
    tags = {
        Name = "Publicsubnet2"
    }
}

resource "aws_subnet" "Privatesubnet1"{
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = "us-east-2b"
    tags = {
        Name = "Privatesubnet1"
    }
}

resource "aws_subnet" "Privatesubnet2"{
    vpc_id = aws_vpc.Myvpc.id
    cidr_block = var.private_subnet2_cidr
    availability_zone = "us-east-2c"
    tags = {
        Name = "Privatesubnet2"
    }
}

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.Myvpc.id
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "publicRT" {
    vpc_id = aws_vpc.Myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}
resource "aws_route_table_association" "PublicRTAssociation" {
    subnet_id = aws_subnet.Publicsubnet1.id
    route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table_association" "PublicRTAssociationn" {
    subnet_id = aws_subnet.Publicsubnet2.id
    route_table_id = aws_route_table.publicRT.id
}

resource "aws_nat_gateway" "Nat_gateway" {
  allocation_id = var.elasticip
  subnet_id     = aws_subnet.Publicsubnet1.id
  tags = {
    Name = "Natgateway"
  }
}

resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.Myvpc.id
  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id         = aws_nat_gateway.Nat_gateway.id
  }
  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "privateRTassociation" {
  subnet_id      = aws_subnet.Privatesubnet1.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route_table_association" "privateRTassociationn" {
  subnet_id      = aws_subnet.Privatesubnet2.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_security_group" "frontendCG" {
  vpc_id      = aws_vpc.Myvpc.id
  name = "FrontendCG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backendCG" {
  vpc_id      = aws_vpc.Myvpc.id
  name        = "BackendCG"
  description = "SG for backend"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontendCG.id]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontendCG.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "databaseCG" {
  vpc_id      = aws_vpc.Myvpc.id
  name        = "CfDatabase"
  description = "SG for database"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontendCG.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backendCG.id]
  }

}

resource "aws_instance" "frontend_instance" {
  ami           = var.frontendami
  instance_type = "t2.micro"
  key_name      = "chatappkey"
  subnet_id     = aws_subnet.Publicsubnet1.id
  vpc_security_group_ids = [aws_security_group.frontendCG.id]
  associate_public_ip_address = true

  tags = {
    Name = "FrontendInstance"
  }
}

resource "aws_instance" "backend_instance" {
  ami           = var.backendami
  instance_type = "t2.micro"
  key_name      = "chatappkey"
  subnet_id     = aws_subnet.Privatesubnet1.id
  vpc_security_group_ids = [aws_security_group.backendCG.id]

  tags = {
    Name = "BackendInstance"
  }
}

resource "aws_instance" "database_instance" {
  ami           = var.databaseami
  instance_type = "t2.micro"
  key_name      = "chatappkey"
  subnet_id     = aws_subnet.Privatesubnet2.id
  vpc_security_group_ids = [aws_security_group.databaseCG.id]

  tags = {
    Name = "DatabaseInstance"
  }
}

resource "aws_launch_template" "backendLT" {
  name        = "LTBackend_TF"
  image_id    = var.backendami
  instance_type = "t2.micro"
  key_name    = "chatappkey"

  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    security_groups             = [aws_security_group.backendCG.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "TFBackendLT"
    }
  }
}

resource "aws_launch_template" "frontendLT" {
  name          = "LTFrontend"
  image_id      = var.frontendami
  instance_type = "t2.micro"
  key_name      = "chatappkey"

  network_interfaces {
    associate_public_ip_address = true
    device_index                = 0
    security_groups             = [aws_security_group.frontendCG.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "LTFrontend"
    }
  }
}

resource "aws_security_group" "backend_LBSG" {
  name        = "backend-LBSG"
  description = "Security group for backend load balancer using terraform"
  vpc_id      = aws_vpc.Myvpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Backend_lb_sg"
  }
}

resource "aws_security_group" "frontend_LBSG" {
  name        = "frontend-LBSG"
  description = "Security group for frontend load balancer using terraform"
  vpc_id      = aws_vpc.Myvpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Frontend_lb_sg"
  }
}

resource "aws_lb_target_group" "backendTG" {
  name        = "backend-tg"
  protocol    = "HTTP"
  port        = 8000
  vpc_id      = aws_vpc.Myvpc.id
  target_type = "instance"
}


resource "aws_lb_target_group" "frontendTG" {
  name        = "frontend-tg"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = aws_vpc.Myvpc.id
  target_type = "instance"
}

resource "aws_lb" "backendLB" {
  name               = "lb-backend"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_LBSG.id]
  subnets            = [aws_subnet.Privatesubnet1.id, aws_subnet.Privatesubnet2.id]

  tags = {
    Name = "lb-backend"
  }
}

resource "aws_lb_listener" "backendlist" {
  load_balancer_arn = aws_lb.backendLB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backendTG.arn
  }
}

resource "aws_lb" "frontendLB" {
  name               = "lb-frontend-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_LBSG.id]
  subnets            = [aws_subnet.Publicsubnet1.id, aws_subnet.Publicsubnet2.id]

  tags = {
    Name = "lb-frontend"
  }
}

resource "aws_lb_listener" "frontendlist" {
  load_balancer_arn = aws_lb.frontendLB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontendTG.arn
  }
}





    