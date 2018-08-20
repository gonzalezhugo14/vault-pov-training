provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "vpc_manuel_training"
  cidr = "10.0.0.0/16"
  az = ["us-west-1"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "test"
    owner = "manuel.portillo"
  }
}


resource "aws_key_pair" "training" {
  key_name   = "vault_training_${var.my_name}_${random_id.training.hex}"
  public_key = "${var.public_key}"
}

resource "aws_instance" "vault_training_instance" {
  ami                         = "${var.training_ami}"
  count                       = "3"
  instance_type               = "t2.small"
  associate_public_ip_address = "true"
  security_groups             = ["${aws_security_group.vault_training.name}"]
  key_name                    = "${aws_key_pair.training.key_name}"

  tags {
    Name = "HashiCorp_Training_August_2018_${var.my_name}_${random_id.training.hex}"
    TTL = "24"
  }
}

// Outputs
output "Your EC2 instances:" {
    value = "${aws_instance.vault_training_instance.*.public_dns}"
}

output "Your EC2 instance IP addresses:" {
    value = "${aws_instance.vault_training_instance.*.public_ip}"
}

output "Access to your VMs:" {
    value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.vault_training_instance.0.public_dns}"
}

output "Vault UI access (after installation):" {
    value = "http://${aws_instance.vault_training_instance.0.public_dns}:8200"
}

output "Consul UI access (after installation):" {
    value = "http://${aws_instance.vault_training_instance.0.public_dns}:8300"
}

output "AWS Key Name" {
    value = "${aws_key_pair.training.key_name}"
}

output "vpc_id"{
    value = "${module.vpc.vpc_id}"
}