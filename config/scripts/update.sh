#!/bin/bash

set -e

cd /var/www/web;

for x in `ls /var/www/web/sites`; do
  if [ -f "/var/www/web/sites/$x/settings.php" ]; then
    drush -l $x cr
    drush -l $x -y updb
    if [ -n "$SKIP_WEBFORM_IMPORT" ]; then
      mkdir -p /tmp/config-export/
      drush config-export -l $x -y --destination=/tmp/config-export/
      cp /tmp/config-export/webform.webform* /var/www/config/sync/
      rm -Rf /tmp/config-export
    fi
    drush -l $x -y cim
    drush -l $x cr
    if [ -f "../translations/nl.po" ]; then
      drush language-import ../translations/nl.po
    fi
  fi
done
