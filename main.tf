data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name_pattern}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.ami_publisher}"]
}

data "template_file" "user_data" {
  template = "${file("${path.module}/nat-user-data.conf.tmpl")}"
  count = "${var.instance_count}"

  vars {
    myaz = "${element(var.az_list, count.index)}"
    networkprefix = "${var.networkprefix}"
  }
}

resource "aws_instance" "nat" {
    count = "${var.instance_count}"
    ami = "${data.aws_ami.ami.id}"
    instance_type = "${var.instance_type}"
    source_dest_check = false
    iam_instance_profile = "${aws_iam_instance_profile.nat_profile.id}"
    key_name = "${var.aws_key_name}"
    subnet_id = "${element(var.subnet_ids, count.index)}"
    vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
    tags {
        Name = "NAT ${element(var.az_list, count.index)}${count.index+1}"
    }
    user_data = "${element(data.template_file.user_data.*.rendered, count.index)}"
    provisioner "remote-exec" {
        inline = [
          "while sudo pkill -0 cloud-init; do sleep 2; done"
        ]
        connection {
          user = "ubuntu"
          private_key = "${var.aws_key_location}"
        }
    }
}

