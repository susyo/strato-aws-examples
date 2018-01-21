# Filter a centos based image
data "aws_ami" "linux"{
    filter{
        name="name"
        values=["*centos*"]
    }
}

# Create 3 instances, and name them according to count
resource "aws_instance" "ec2_instance" {
    ami = "${data.aws_ami.linux.image_id}"

    tags{
        Name="instance${count.index}"
    }
    # Can use any aws instance type supported by symphony
    instance_type = "t2.micro"
    count=3
}