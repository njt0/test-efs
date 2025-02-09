output "vpc_cidr" {
  value = data.aws_vpc.default.cidr_block
}

output "subnet_cidr" {
  value = data.aws_subnet.subnet.cidr_block
}

output "subnets" {
  value = data.aws_subnet.subnet.*.id
}