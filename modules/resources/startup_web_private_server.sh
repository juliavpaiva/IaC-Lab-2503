#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade

sudo amazon-linux-extras install epel -y 
sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
sudo yum install mysql-community-server

sudo amazon-linux-extras list | grep nginx
sudo amazon-linux-extras enable nginx1
sudo yum clean metadata
sudo yum -y install nginx