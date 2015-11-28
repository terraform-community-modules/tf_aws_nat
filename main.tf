module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.instance_type}"
  region = "${var.region}"
  distribution = "vivid"
}

resource "aws_instance" "nat" {
    count = "${var.instance_count}"
    ami = "${module.ami.ami_id}"
    instance_type = "${var.instance_type}"
    source_dest_check = false
    key_name = "${var.aws_key_name}"
    subnet_id = "${element(split(\",\", var.subnet_ids), count.index)}"
    security_groups = ["${split(\",\", var.security_groups)}"]
    tags {
        Name = "NAT ${element(split(\",\", var.az_letters), count.index)}${count.index+1}"
    }
    user_data = "${replace(file(\"${path.module}/nat.conf\"), \"__NETWORKPREFIX__\", \"${var.networkprefix}\")}"
    provisioner "remote-exec" {
        inline = [
          "while sudo pkill -0 cloud-init; do sleep 2; done"
        ]
        connection {
          user = "ubuntu"
          key_file = "${var.aws_key_location}"
        }
    }
}

