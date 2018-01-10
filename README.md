# tf_aws_nat 

## Module to launch NAT instances on AWS.

## Inputs

  * ami_name_pattern
  * ami_publisher
  * instance_type
  * instance_count
  * az_list
  * public_subnet_ids
  * private_subnet_ids
  * security_groups
  * aws_key_name
  * aws_key_location
  * tags

## Outputs

  * private_ips
  * public_ips
  * instance_ids

## Usage
```hcl
resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow nat traffic"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 49152
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 49152
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle = {
    create_before_destroy = true
  }
}

module "nat" {
  source                 = "github.com/terraform-community-modules/tf_aws_nat"
  name                   = "${var.name}"
  instance_type          = "t2.nano"
  instance_count         = "2"
  aws_key_name           = "mykeyname"
  public_subnet_ids      = "${module.vpc.public_subnets}"
  private_subnet_ids     = "${module.vpc.private_subnets}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  az_list                = "${var.azs}"
  subnets_count          = "${length(var.azs)}"
  route_table_regexp     = "$${name}-private-$${region}[a-z]"
  ssh_bastion_user       = "ubuntu"
  ssh_bastion_host       = "${aws_instance.bastion.public_ip}"
  aws_key_location       = "${file("pathtokeyfile")}"
}
```

# LICENSE

Apache2, see the included LICENSE file for more information.

