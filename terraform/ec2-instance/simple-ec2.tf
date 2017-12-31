resource "aws_instance" "ec2_instance" {
    ami = "${var.example_ami}"

    tags{
        Name="ec2"
    }
    # Can use any aws instance type supported by symphony
    instance_type = "t2.micro"
}
