# Creating a VPC & Networking
resource "aws_vpc" "myapp_vpc" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = false
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.myapp_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
resource "aws_subnet" "myapp_subnet"{
    cidr_block = "192.168.10.0/24"
    vpc_id = "${aws_vpc.myapp_vpc.id}"
}

resource "aws_internet_gateway" "myapp_gw" {
  vpc_id = "${aws_vpc.myapp_vpc.id}"
}

# The subnet is required due to a limitation in Symphony
resource "aws_route_table" "subnet_access" {
  vpc_id = "${aws_vpc.myapp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myapp_gw.id}"
  }
}

resource "aws_route_table_association" "subnet_rtb_assoc" {
  subnet_id      = "${aws_subnet.myapp_subnet.id}"
  route_table_id = "${aws_route_table.subnet_access.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = "${aws_vpc.myapp_vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 1
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol        = "tcp"
    from_port       = 1
    to_port         = 65535
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol    = "udp"
    from_port   = 1
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol        = "udp"
    from_port       = 1
    to_port         = 65535
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

##################

# Creating an instance
resource "aws_instance" "myapp_instance" {
    ami = "${var.ami_my_image}"
    instance_type = "${var.instance_type}"
    subnet_id = "${aws_subnet.myapp_subnet.id}"
    associate_public_ip_address = true
    key_name = "${var.keypair}"
    security_groups = ["${aws_security_group.allow_all.id}"]
    count = "${var.count}"
}

resource "aws_eip" "myapp_instance_eip" {
  count = "${var.count}"
  depends_on = ["aws_internet_gateway.myapp_gw"]
}

resource "aws_eip_association" "myapp_eip_assoc" {
  count = "${var.count}"
  instance_id = "${element(aws_instance.myapp_instance.*.id, count.index)}"
  allocation_id = "${element(aws_eip.myapp_instance_eip.*.id, count.index)}"
}



