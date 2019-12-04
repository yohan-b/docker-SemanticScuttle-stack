#!/bin/bash
unset VERSION_APACHE_FPM
unset VERSION_PHP_FPM
VERSION_APACHE_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-apache-for-fpm.git| head -1 | cut -f 1|cut -c -10) \
VERSION_PHP_FPM=$(git ls-remote https://git.scimetis.net/yohan/docker-php5-fpm.git| head -1 | cut -f 1|cut -c -10) \
 sudo -E bash -c 'docker-compose up -d'
