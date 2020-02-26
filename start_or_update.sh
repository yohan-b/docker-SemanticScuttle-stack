#!/bin/bash
source ~/openrc.sh
INSTANCE=$(/home/yohan/env_py3/bin/openstack server show -c id --format value $(hostname))
mkdir -p /mnt/volumes/scuttle_code /mnt/volumes/scuttle_php5-fpm_conf
if ! mountpoint -q /mnt/volumes/scuttle_code
then
     VOLUME_ID=$(/home/yohan/env_py3/bin/openstack volume show scuttle_code -c id --format value)
     test -e /dev/disk/by-id/*${VOLUME_ID:0:20} || nova volume-attach $INSTANCE $VOLUME_ID auto
     sleep 3
     sudo mount /dev/disk/by-id/*${VOLUME_ID:0:20} /mnt/volumes/scuttle_code
fi
if ! mountpoint -q /mnt/volumes/scuttle_php5-fpm_conf
then
     VOLUME_ID=$(/home/yohan/env_py3/bin/openstack volume show scuttle_php5-fpm_conf -c id --format value)
     test -e /dev/disk/by-id/*${VOLUME_ID:0:20} || nova volume-attach $INSTANCE $VOLUME_ID auto
     sleep 3
     sudo mount /dev/disk/by-id/*${VOLUME_ID:0:20} /mnt/volumes/scuttle_php5-fpm_conf
fi

unset VERSION_APACHE_FPM VERSION_PHP_FPM
export VERSION_APACHE_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-apache-for-fpm.git| head -1 | cut -f 1|cut -c -10)
export VERSION_PHP_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-php5-fpm.git| head -1 | cut -f 1|cut -c -10)

mkdir -p ~/build
git clone https://git.scimetis.net/yohan/docker-apache-for-fpm.git ~/build/docker-apache-for-fpm
sudo docker build -t apache-scuttle:$VERSION_APACHE_FPM ~/build/docker-apache-for-fpm
git clone https://git.scimetis.net/yohan/docker-php5-fpm.git ~/build/docker-php5-fpm
sudo docker build -t php5-fpm:$VERSION_PHP_FPM ~/build/docker-php5-fpm

sudo -E bash -c 'docker-compose up -d'

rm -rf ~/build
