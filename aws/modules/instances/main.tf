resource "aws_instance" "ami_id" {
  name                    = "${var.image}"
}