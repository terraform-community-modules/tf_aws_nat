module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.instance_type}"
  region = "${var.region}"
  distribution = "trusty"
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
        Name = "NAT ${element(split(\",\", module.vpc.az_letters), count.index)}${count.index+1}"
    }
    user_data = "#cloud-config\napt_sources:\n - source: \"deb https://get.docker.io/ubuntu docker main\"\n   keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9\n - source: \"deb http://apt.puppetlabs.com trusty main\"\n   keyid: 1054b7a24bd6ec30\napt_upgrade: true\nlocale: en_US.UTF-8\npackages:\n - lxc-docker\n - puppet\n - git\nruncmd:\n - [ iptables, -N, LOGGINGF ]\n - [ iptables, -N, LOGGINGI ]\n - [ iptables, -A, LOGGINGF, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, \"IPTables-FORWARD-Dropped: \", --log-level, 4 ]\n - [ iptables, -A, LOGGINGI, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, \"IPTables-INPUT-Dropped: \", --log-level, 4 ]\n - [ iptables, -A, LOGGINGF, -j, DROP ]\n - [ iptables, -A, LOGGINGI, -j, DROP ]\n - [ iptables, -A, FORWARD, -s, ${var.networkprefix}.0.0/16, -j, ACCEPT ]\n - [ iptables, -A, FORWARD, -j, LOGGINGF ]\n - [ iptables, -P, FORWARD, DROP ]\n - [ iptables, -I, FORWARD, -m, state, --state, \"ESTABLISHED,RELATED\", -j, ACCEPT ]\n - [ iptables, -t, nat, -I, POSTROUTING, -s, ${var.networkprefix}.0.0/16, -d, 0.0.0.0/0, -j, MASQUERADE ]\n - [ iptables, -A, INPUT, -s, ${var.networkprefix}.0.0/16, -j, ACCEPT ]\n - [ iptables, -A, INPUT, -p, tcp, --dport, 22, -m, state, --state, NEW, -j, ACCEPT ]\n - [ iptables, -I, INPUT, -m, state, --state, \"ESTABLISHED,RELATED\", -j, ACCEPT ]\n - [ ifconfig, \"lo:consul\", up, 10.255.255.253/32 ]\n - [ iptables, -I, INPUT, -i, lo, -j, ACCEPT ]\n - [ iptables, -I, INPUT, -d, 10.255.255.253/32, -s, ${var.networkprefix}.0.0/16, -j, ACCEPT ]\n - [ iptables, -A, INPUT, -j, LOGGINGI ]\n - [ iptables, -P, INPUT, DROP ]\n - [ /usr/bin/docker, run, --net=host, -d, --name, consul, bobtfish/consul-awsnycast, -dc, ${var.region}-${var.account}, -bootstrap  ]\n - [ /usr/bin/docker, run, --rm, -v, \"/usr/local/bin:/target\", jpetazzo/nsenter ]\n"
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

