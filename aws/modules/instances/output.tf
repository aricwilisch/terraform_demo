output "ami_out" {
    value = "${aws_ami.ami_id.latest}"
}