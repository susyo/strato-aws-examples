#! /bin/bash -v

export DBHOST=${db_ip}
export DBUSER=${db_user}
export DBPASSWORD=${db_password}
export DBNAME=${db_name}
export LC_ALL="en_US.UTF-8"

echo "abcd @@@@ DBHOST: $DBHOST"
echo "abcd @@@@ LC_ALL: $LC_ALL"

echo "@@@@ before update image"
# update image
apt-get update -y
apt-get upgrade -y
echo "@@@@ after update image"

# install docker
apt-get install -y docker.io

#fetch public docker wordpress container
docker pull wordpress

# run docker container

docker run --name wpsite -e WORDPRESS_DB_HOST=$DBHOST:3306 -e WORDPRESS_DB_USER=$DBUSER -e WORDPRESS_DB_PASSWORD=$DBPASSWORD -p 8080:80 -d wordpress