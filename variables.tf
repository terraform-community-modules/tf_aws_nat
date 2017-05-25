variable "region" {}
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

