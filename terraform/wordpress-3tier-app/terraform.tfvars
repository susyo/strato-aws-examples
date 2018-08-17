# Sample tfvars file 
# Stratoscale Symphony credentials

symp_access_key = ""
symp_secret_key = ""
symphony_ip = ""

# Number of web servers (Load balancer will automatically manage target groups)
web_number = "2"

# Use Public Xenial cloud image ami

# Recommend use of Xenial's latest cloud image
# located here: https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
web_ami = ""
web_instance_type = "t2.medium"

#Database Information (wordpress containe will use wordpress database by default)

db_user = "admin"
db_password = "Stratoscale!Orchestration!"




