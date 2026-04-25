resource "aws_security_group" "security_group_ssh" {
  name   = "${var.project_name}-security-group-ssh"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "security_group_http" {
  name   = "${var.project_name}-security-group-http"
  vpc_id = var.vpc_id

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
}


resource "aws_security_group" "security_group_MongoDB" {
  name   = "${var.project_name}-security-group-MongoDB"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 27017
    to_port     = 27017
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.0.0.0/16"]
  }
}


resource "aws_security_group" "security_group_mongoDB-exporter" {
  name   = "${var.project_name}-security-group-mongoDB-exporter"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 9216
    to_port     = 9216
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "security_group_monitoring" {
  name   = "${var.project_name}-security-group-monitoring"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}