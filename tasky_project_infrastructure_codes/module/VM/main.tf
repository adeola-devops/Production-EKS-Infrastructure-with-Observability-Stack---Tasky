resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  key_name                    = var.key_name
  user_data                   = var.user_data 
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.project_name}-instance"
  }
}