resource "aws_vpc" "vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  tags = {
   Name = "VPC-${local.project_name}"
 }
}

resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.vpc.id
 tags = {
   Name = "InternetGateway-${local.project_name}-${terraform.workspace}"
 }
}

resource "aws_subnet" "public_subnet" {
    count = var.public_subnet_count
    vpc_id            = aws_vpc.vpc.id
    cidr_block = "10.20.${10+count.index}.0/24"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "PublicSubnet-${local.project_name}-${count.index}-${terraform.workspace}"
    }
}

resource "aws_subnet" "private_subnet" {
    count = var.private_subnet_count
    vpc_id            = aws_vpc.vpc.id
    cidr_block = "10.20.${20+count.index}.0/24"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = false
    
    tags = {
        Name = "PrivateSubnet-${local.project_name}-${count.index}-${terraform.workspace}"
    }
}

resource "aws_security_group" "server_security_group" {
  count = 2
  name        = "security_group_${count.index}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }

  tags = {
    "Name" = "ServerSecurityGroup-${count.index}-${local.project_name}-${terraform.workspace}"
  }
}

resource "aws_instance" "web_public_server" {
    count = var.web_public_server_count
    ami = var.ubuntu_ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.public_subnet[0].id
    vpc_security_group_ids = [aws_security_group.server_security_group[0].id]

    user_data = file("${path.module}/startup_web_public_server.sh")

    root_block_device {
      volume_type = "gp3"
      volume_size = "20"
    }

    tags = {
        Name = "WebPublic-Server-AmzLinux-${count.index}-${local.project_name}-${terraform.workspace}"
        }
}

resource "aws_instance" "web_private_server" {
    count = var.web_private_server_count
    ami = var.amazon_linux_ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.private_subnet[1].id
    vpc_security_group_ids = [aws_security_group.server_security_group[1].id]

    root_block_device {
      volume_type = "gp3"
      volume_size = var.web_private_server_volume_size
    }

    user_data = file("${path.module}/startup_web_private_server.sh")

    tags = {
        Name = "WebPrivate-Server-AmzLinux-${count.index}-${local.project_name}-${terraform.workspace}"
        }
}

resource "aws_security_group" "load_balancer_security_group" {
  name        = "terraform_alb_secuload_balancer_security_grouprity_group"
  vpc_id      = "${aws_vpc.vpc.id}"

  dynamic "ingress" {
    for_each = local.web_ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.web_egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    "Name" = "LBSecurityGroup-${local.project_name}-${terraform.workspace}"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "LoadBalancer-${local.project_name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    "Name" = "LoadBalancer-${local.project_name}-${terraform.workspace}"
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "RDSSecurityGroup-${local.project_name}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]

  tags = {
    Name = "DBSunbnetGroup-${local.project_name}-${terraform.workspace}"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "rds-instance-${lower(terraform.workspace)}"
  db_name                = "rds"
  instance_class         = "db.t2.micro"
  allocated_storage      = var.rds_instance_volume_size
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0.25"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.name}"
  username               = "iacTestUser"
  password               = "userPassTest"
  multi_az               =  "${terraform.workspace == "Prod" ? true : false}"

  tags = {
    "Name" = "RDS-${local.project_name}-${terraform.workspace}"
	  }
}