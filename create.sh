#!/bin/bash
#Absolute path to this script
SCRIPT=$(readlink -f $0)
#Absolute path this script is in
SCRIPTPATH=$(dirname $SCRIPT)

cd $SCRIPTPATH

unset VERSION_APACHE_FPM VERSION_PHP_FPM
export VERSION_APACHE_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-apache-for-fpm.git| head -1 | cut -f 1|cut -c -10)
export VERSION_PHP_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-php5-fpm.git| head -1 | cut -f 1|cut -c -10)

mkdir -p ~/build
git clone https://git.scimetis.net/yohan/docker-apache-for-fpm.git ~/build/docker-apache-for-fpm
sudo docker build -t apache-scuttle:$VERSION_APACHE_FPM ~/build/docker-apache-for-fpm
git clone https://git.scimetis.net/yohan/docker-php5-fpm.git ~/build/docker-php5-fpm
sudo docker build -t php5-fpm:$VERSION_PHP_FPM ~/build/docker-php5-fpm

sudo -E bash -c 'docker-compose up --no-start'

rm -rf ~/build
