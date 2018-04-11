#!/bin/bash

cd /var/www/web;

for x in `ls /var/www/web/sites`; do
  if [ -f "/var/www/web/sites/$x/settings.php" ]; then
    drush -l $x -y updb
    drush -l $x -y cim
    drush -l $x cr
  fi
done
