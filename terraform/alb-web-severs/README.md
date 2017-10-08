# Overview - ALB
This terraform will create two webservers from a given ami, and instantiate a load balancer to actively balance them.
To get the ami id, simply fetch the image uuid from the Symphony UI, and convert it to the AWS format:
`ami-<uuid without dashes>`

>This example's load balancer is configured as internal

## Getting started
1. Make sure you have the latest terraform installed
2. Create/Specify a security group
3. Modify the `terraform.tfvars` file according to your environment
4. Run `terraform apply`

## Notes
The script assumes the local default network can be routed using an existing VLAN
