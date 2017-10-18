#!/bin/bash

rm -rf /run/httpd/*
chmod 777 /var/www/media
chmod 777 /mnt/reports

./composer/vendor/bin/browscap-php browscap:update --cache ./composer/__cache --remote-file Lite_PHP_BrowscapINI
chmod 777 -R ./composer/__cache

exec /usr/sbin/apachectl -D FOREGROUND