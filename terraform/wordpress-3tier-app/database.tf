# Create db instance 

#make db subnet group 
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "main"
  subnet_ids = ["${aws_subnet.db_subnet.id}"]
}

#provision the database
resource "aws_db_instance" "wpdb" {
  identifier = "wpdb"
  instance_class = "db.m1.medium"
  allocated_storage = 50
  engine = "mysql"
  name = "${var.db_name}"
  password = "${var.db_password}"
  username = "${var.db_user}"
  engine_version = "5.7.00"
  skip_final_snapshot = true
  db_subnet_group_name = "${aws_db_subnet_group.dbsubnet.name}"
  lifecycle {
    ignore_changes = ["engine", "auto_minor_version_upgrade"]
  }
}

