###################################
# Creating a VPC & Networking
###################################

resource "aws_vpc" "default" {
    cidr_block = "10.48.0.0/16"
    enable_dns_support = true
  tags {
    Name = "ALB Example VPC"
  }
}

resource "aws_subnet" "subnet1"{
    cidr_block = "10.48.1.0/24"
    vpc_id = "${aws_vpc.default.id}"
}


###################################
# Cloud init data

data "template_cloudinit_config" "web_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "webconfig.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.web.rendered}"
  }
}

###################################

# Creating two instances of web server ami with cloudinit
resource "aws_instance" "web1" {
    ami = "${var.ami_webserver}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet1.id}"

    vpc_security_group_ids = ["${aws_security_group.web-sec.id}", "${aws_security_group.allout.id}"]
    user_data = "${data.template_cloudinit_config.web_config.rendered}"
}

resource "aws_instance" "web2" {
    ami = "${var.ami_webserver}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet1.id}"

    vpc_security_group_ids = ["${aws_security_group.web-sec.id}", "${aws_security_group.allout.id}"]
    user_data = "${data.template_cloudinit_config.web_config.rendered}"
}


##################################
# Security group definitions

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
  #ssh from anywhere (for debugging)
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
}

#public access sg 

# allow all egress traffic (needed for server to download packages)
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

##################################

# Creating and attaching the load balancer
resource "aws_alb" "alb" {
    subnets = ["${aws_subnet.subnet1.id}"]
    internal = true
}

resource "aws_alb_target_group" "targ" {
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_alb_target_group_attachment" "attach_web1" {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    target_id       = "${aws_instance.web1.id}"
    port             = 80
}

resource "aws_alb_target_group_attachment" "attach_web2" {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    target_id       = "${aws_instance.web2.id}"
    port             = 80
}

resource "aws_alb_listener" "list" {
    "default_action" {
        target_group_arn = "${aws_alb_target_group.targ.arn}"
        type = "forward"
    }
    load_balancer_arn = "${aws_alb.alb.arn}"
    port = 8080
}