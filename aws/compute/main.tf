#-----compute/main.tf

data "aws_ami" "centos7" {
  most_recent = true

  owners = ["679593333241"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
}

resource "aws_key_pair" "techops-admin" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

data "template_file" "${var.provides}" {
  count    = 2
  template = file("${path.root}/${var.salt_ubuntu}")

  vars = {
    env              = var.env
    salt_environment = var.salt_environment
    hostname         = format("%s-%s-%02d", var.env, var.provides, count.index + 1)
    role             = var.provides
  }
}

resource "aws_instance" "${var.provides}" {
  count         = "${var.instance_count}"
  instance_type = "${var.instance_type}"
  ami           = "${data.aws_ami.server_ami.id}"

  tags {
    Name = "tf_server-${count.index +1}"
  }

  key_name               = "${aws_key_pair.tf_auth.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index)}"
  user_data              = "${data.template_file.user-init.*.rendered[count.index]}"
}
