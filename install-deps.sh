apt-get update
apt-get -y upgrade
 
# Basic Requirements
apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip

# Moodle Requirements
apt-get -y install apache2 php5 php5-gd libapache2-mod-php5 postfix wget supervisor php5-pgsql vim curl libcurl3 libcurl3-dev php5-curl php5-xmlrpc php5-intl php5-mysql

easy_install supervisor
./start.sh /start.sh
./foreground.sh /etc/apache2/foreground.sh
./supervisord.conf /etc/supervisord.conf

# curl https://download.moodle.org/moodle/moodle-latest.tgz > /var/www/moodle-latest.tgz
# cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
# chown -R www-data:www-data /var/www/html/moodle
# mkdir /var/moodledata
# chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
# chmod 755 /start.sh /etc/apache2/foreground.sh