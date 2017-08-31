# Overview - Simple EC2 Instance
This terraform example creates a very simple ec2 instance from an ami.\n
To get the ami id, simply fetch the image uuid from the Symphony UI, and convert it to the AWS format:
`ami-<uuid without dashes>`

## Getting started
1. Make sure you have the latest terraform installed
2. Modify the `terraform.tfvars` file according to your environment
3. Run `terraform apply`

