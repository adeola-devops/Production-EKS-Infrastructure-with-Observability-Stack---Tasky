output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "public_subnet_id" {
    value = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

output "private_subnet_id" {
    value = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

output "eip" {
    value = aws_eip.eip.id
}

output "nat_gateway" {
    value = aws_nat_gateway.nat_gateway.id
}