#!/bin/bash

cd /var/www/web;

for x in `ls /var/www/web/sites`; do
  if [ -f "/var/www/web/sites/$x/settings.php" ]; then
    drush -l $x cr
    if [ $? -ne 0 ]; then
      exit 1
    fi
    drush -l $x -y updb
    if [ $? -ne 0 ]; then
      exit 1
    fi
    drush -l $x -y cim
    if [ $? -ne 0 ]; then
      exit 1
    fi
    drush -l $x cr
    if [ $? -ne 0 ]; then
      exit 1
    fi
    if [ -f ../translations/nl.po ]: then
      drush language-import ../translations/nl.po
    fi
  fi
done
