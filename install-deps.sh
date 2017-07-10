# FROM ubuntu:16.10
# MAINTAINER Sergio Gómez <sergio@quaip.com>

# Keep upstart from complaining
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

apt-get update
apt-get -y upgrade
 
# Basic Requirements
apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip

# Moodle Requirements
apt-get -y install apache2 postfix wget supervisor vim curl libcurl3 libcurl3-dev
apt-get -y install php php-mysql php-xml php-curl php-zip php-gd php-xmlrpc php-soap php-mbstring php-intl

# SSH
apt-get -y install openssh-server
mkdir -p /var/run/sshd

# apache required dirs
mkdir -p /var/run/apache2
mkdir -p /var/lock/apache2

# mysql required dirs
mkdir -p /var/run/mysqld
chown mysql /var/run/mysqld

# mysql config
sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

easy_install supervisor

# Copy the files to the root
cp ./start.sh /start.sh
cp ./foreground.sh /etc/apache2/foreground.sh
cp ./supervisord.conf /etc/supervisord.conf

# Download Moodle
curl https://download.moodle.org/stable33/moodle-latest-33.tgz -o /var/www/moodle-latest.tgz

cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
chown -R www-data:www-data /var/www/html/moodle
mkdir /var/moodledata
chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
chmod 755 /start.sh /etc/apache2/foreground.sh

# EXPOSE 22 80
# CMD ["/bin/bash", "/start.sh"]

