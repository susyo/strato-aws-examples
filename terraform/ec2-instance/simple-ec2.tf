resource "aws_instance" "ec2_instance" {
    ami = "${var.example-ami}"

    # Can use any aws instance type supported by symphony
    instance_type = "t2.micro"
}
