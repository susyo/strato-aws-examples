# Symphony and Ansible Integration Examples

## General Information
The examples will help you get started with running Ansible orchestration and configuration with Stratoscale Symphony.
Currently there are two examples available:
1. ec2-instance - A simple single task playbook that shows how to start an AWS instance.
2. tag-provision - An example to a full provisioning scenario of an AWS instances using dynamic inventory

*Both example are for EC2-Classic network schemes. EC2-VPC will be available soon.*

## Recommended configuration

### Dynamic inventory
Please use the ec2.py and ec2.ini in this repository which support Symphony EC2 endpoint.

**The AWS EC2 dynamic inventory available in the Ansible official repository will not allow hosts discovery in Symphony**

#### ec2.py and ec2.ini
+ Recommended is to copy ec2.py to _hosts_ default location /etc/ansible/hosts.
+ Another option is to run ansible-playbook -i .../ec2.py

**In both cases ec2.ini should be placed in the same directory**

#### ec2.ini 
+ *enable collect dynamic inventory from Symphony*
```
symphony = True
symphony_host = https://example.acme.com/api/v2/ec2/
```

+ *collect dynamic inventory from Symphony on every call refresh-inventory command*
```
cache_max_age = 0
```

+ disable inventory collection of services other than EC2 __- Will be supported soon__ * 
```
rds = False
elasticache = False
```

#### ansible.cfg 
```
private_key_file = /full/path/to/ssh_private_key_file
```

### AWS credentials

Accessing Stratoscale's Symphony is done using access and secret keys, exactly as in the AWS format.
The credentials are used for both Ansible tasks and dynamic inventory.

Access and secret can be used in the following ways:
1. Set environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY - __Recommended__
2. Set access and secret keys in ~/.aws/credentials file.
3. Set access and secret keys in ec2.ini *credentials* section. 

