# tf_aws_nat 

## Module to launch NAT instances on AWS.

This module will provision a specified number of nat instances in the public subnets to allow 
outbound internet traffic from the private subnets. For route publishing and High Availability
each instance runs the [AWSnycast](https://github.com/bobtfish/AWSnycast) service. If the nat
instance becomes unavailable it will remove the instance from the route table (this requires
at least 2 instances). NAT instances are an alternative to NAT Gateways to determine which one
is best for your use case please see the following:

* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-comparison.html
* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html
* https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html

## Inputs

  * `ami_name_pattern` - The regex to filter which ami used (defaults to Ubuntu Xenial 16.04)
  * `ami_publisher` - The ami publisher id (defaults to Canonical's)
  * `instance_type` - The type of instance to provision (required)
  * `instance_count` - The number of nat instances to provision. At least two are required for HA. It is recommended to have one per subnet (required)
  * `az_list` - A list of availability zones to provision in (required)
  * `public_subnet_ids` - A list of the public subnets to provision in (required)
  * `private_subnet_ids` - A list of the private subnets to allow traffic from (required)
  * `security_groups` - A list of security groups applied to the nat instances (required)
  * `aws_key_name` - The name of the AWS key pair to provision the instances with (required)
  * `ssh_bastion_host` - The ip of the bastion host
  * `ssh_bastion_user` - The name of bastion user (required for ssh_bastion_host)
  * `aws_key_location` - The contents of private key file for the bastion instance (required for ssh_bastion_host)
  * `tags` - A list of tags to apply to the nat instances
  * `route_table_identifier` - The identifier used in the route table regexp used by AWSnycast. For backwards compatibility it defaults to "rt-private". If you are using the terraform-aws-vpc module you will need to set its value to "private"

## Outputs

  * `private_ips` - A list of the nat instances private ips
  * `public_ips` - A list of the nat instances public ips
  * `instance_ids` - A list of the nat instance ids

## Usage
```hcl
resource "aws_security_group" "nat" {
  name = "nat"
  description = "Allow nat traffic"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
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
  route_table_identifier = "private"
  ssh_bastion_user       = "ubuntu"
  ssh_bastion_host       = "${aws_instance.bastion.public_ip}"
  aws_key_location       = "${file("pathtokeyfile")}"
}
```

# LICENSE

Apache2, see the included LICENSE file for more information.

