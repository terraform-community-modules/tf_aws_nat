output "private_ips" {
  value = "${join(\",\", aws_instance.nat.*.private_ip)}"
}
output "public_ips" {
  value = "${join(\",\", aws_instance.nat.*.public_ip)}"
}
output "instance_ids" {
  value = "${join(\",\", aws_instance.nat.*.id)}"
}
