variable "ami_name_pattern" {
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
  description = "The name filter to use in data.aws_ami"
}
variable "ami_publisher" {
  default = "099720109477" # Canonical
  description = "The AWS account ID of the AMI publisher"
}

variable "instance_type" {}
variable "instance_count" {}
variable "az_list" {
  type = "list"
}
variable "networkprefix" {}
variable "subnet_ids" {
  type = "list"
}
variable "vpc_security_group_ids" {
  type = "list"
}
variable "aws_key_name" {}
variable "aws_key_location" {}

