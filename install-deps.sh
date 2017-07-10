#!/bin/bash

# FROM ubuntu:16.10
# MAINTAINER Sergio Gómez <sergio@quaip.com>

# Keep upstart from complaining
# dpkg-divert --local --rename --add /sbin/initctl
# ln -sf /bin/true /sbin/initctl

apt-get update
apt-get -y upgrade
 
# Basic Requirements
apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip

# Moodle Requirements
apt-get -y install apache2 postfix wget supervisor vim curl libcurl3 libcurl3-dev
apt-get -y install php php-mysql php-xml php-curl php-zip php-gd php-xmlrpc php-soap php-mbstring php-intl

# # SSH
# apt-get -y install openssh-server
# mkdir -p /var/run/sshd

# apache required dirs
mkdir -p /var/run/apache2
mkdir -p /var/lock/apache2

# mysql required dirs
mkdir -p /var/run/mysqld
chown mysql /var/run/mysqld

# mysql config
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# easy_install supervisor

# # Copy the files to the root
# cp ./start.sh /start.sh
# cp ./foreground.sh /etc/apache2/foreground.sh
# cp ./supervisord.conf /etc/supervisord.conf

# Download Moodle
curl https://download.moodle.org/stable33/moodle-latest-33.tgz -o /var/www/moodle-latest.tgz

cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
chown -R www-data:www-data /var/www/html/moodle
mkdir /var/moodledata
chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
# chmod 755 /start.sh /etc/apache2/foreground.sh

# EXPOSE 22 80
# CMD ["/bin/bash", "/start.sh"]

if [ ! -f /var/www/html/moodle/config.php ]; then
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  /usr/bin/mysqld_safe & 
  sleep 10s
  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  MOODLE_DB="moodle"
  MYSQL_PASSWORD=`pwgen -c -n -1 12`
  MOODLE_PASSWORD=`pwgen -c -n -1 12`
  SSH_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo mysql root password: $MYSQL_PASSWORD
  echo moodle password: $MOODLE_PASSWORD
  echo ssh root password: $SSH_PASSWORD
  echo root:$SSH_PASSWORD | chpasswd
  echo $MYSQL_PASSWORD > /mysql-root-pw.txt
  echo $MOODLE_PASSWORD > /moodle-db-pw.txt
  echo $SSH_PASSWORD > /ssh-pw.txt

  sed -e "s/pgsql/mysqli/
  s/username/moodle/
  s/password/$MOODLE_PASSWORD/
  s/example.com/$VIRTUAL_HOST/
  s/\/home\/example\/moodledata/\/var\/moodledata/" /var/www/html/moodle/config-dist.php > /var/www/html/moodle/config.php

  # sed -i 's/PermitRootLogin without-password/PermitRootLogin Yes/' /etc/ssh/sshd_config

  chown www-data:www-data /var/www/html/moodle/config.php

  mysqladmin -u root password $MYSQL_PASSWORD
  mysql -uroot -p $MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  mysql -uroot -p $MYSQL_PASSWORD -e "CREATE DATABASE moodle CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost' IDENTIFIED BY '$MOODLE_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld

  sed -i 's/;error_log.*$/error_log = \/dev\/stderr/' /etc/php/7.0/apache2/php.ini

fi