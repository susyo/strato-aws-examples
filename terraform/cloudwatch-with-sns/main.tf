# Create X instances, and name them according to count
resource "aws_instance" "myapp_instance" {
  ami = "${var.aws_ami}"
  instance_type = "${var.instance_type}"
  count = "${var.instance_count}"
  tags {
    Name = "instance_${count.index}"
  }
  # Can use any aws instance type supported by symphony
}

resource "aws_sns_topic" "topic_name" {
  count = "2"
  name = "${var.sns_topic_name_prefix}${count.index}"
}

# Creating cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "bat" {
  count               = "${var.instance_count}"
  alarm_name          = "${var.cloudwatch_alarm_prefix}${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    InstanceId = "${element(aws_instance.myapp_instance.*.id, count.index)}"
  }

  alarm_description	   	= "This metric monitors insufficient data on ${element(aws_instance.myapp_instance.*.id, count.index)}"
  insufficient_data_actions     = ["${aws_sns_topic.topic_name.*.arn[0]}", "${aws_sns_topic.topic_name.*.arn[1]}"]
  ok_actions                    = ["${aws_sns_topic.topic_name.*.arn[0]}", "${aws_sns_topic.topic_name.*.arn[1]}"]
}
