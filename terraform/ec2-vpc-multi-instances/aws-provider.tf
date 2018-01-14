provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"

    endpoints {
       elb = "https://${var.symphony_ip}/api/v2/aws/elb"
        ec2 = "https://${var.symphony_ip}/api/v2/ec2"
        s3 =  "https://${var.symphony_ip}:1060"
        rds = "https://${var.symphony_ip}/api/v2/aws/rds"
    }

    insecure = "true"
    s3_force_path_style = true
    skip_metadata_api_check = true
    skip_credentials_validation = true

    # No importance for this value currently
    region = "us-west-1"
}
