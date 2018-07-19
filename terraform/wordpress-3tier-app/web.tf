#Deploy Wordpress instances

#Reference to bash script which prepares xenial image
data "template_file" "wpdeploy"{
  template = "${file("./wpdeploy_cloud-init.sh")}"

  vars {
    db_ip = "${aws_db_instance.wpdb.address}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
    db_name = "${var.db_name}"
  }
}

resource "aws_key_pair" "app_keypair" {
  public_key = "${file(var.public_keypair_path)}"
  key_name = "wp_app_kp"
}

resource "aws_instance" "web-server" {
  ami = "${var.web_ami}"
  # The public SG is added for SSH and ICMP
  vpc_security_group_ids = ["${aws_security_group.pub.id}", "${aws_security_group.web-sec.id}", "${aws_security_group.allout.id}"]
  instance_type = "${var.web_instance_type}"
  subnet_id = "${aws_subnet.web_subnet.id}"
  key_name = "${aws_key_pair.app_keypair.key_name}"

  tags {
    Name = "web-server-${count.index}"
  }
  count = "${var.web_number}"
  user_data = "${data.template_file.wpdeploy.rendered}"
}

resource "aws_eip_association" "myapp_eip_assoc_web" {
  instance_id = "${element(aws_instance.web-server.*.id,count.index)}"
  allocation_id = "${element(aws_eip.instance-eip.*.id,count.index)}"
  count = "${var.connect_instances_to_web_ips ? var.web_number : 0}"
}

resource "aws_eip" "instance-eip" {
  vpc = true
  count = "${var.connect_instances_to_web_ips ? var.web_number : 0}"
}

output "web-eips" {
  value = "${join(",",aws_eip.instance-eip.*.public_ip)}"
}

resource "aws_security_group" "web-sec" {
  name = "webserver-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # Internal HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #ssh from anywhere (unnecessary)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#public access sg 
resource "aws_security_group" "pub" {
  name = "pub-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allout" {
  name = "allout-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
