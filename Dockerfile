FROM ubuntu:16.04

EXPOSE 80

ENV LANG=C.UTF-8 \
  SMTP_HOST=mailhog \
  SMTP_PORT=25 \
  SMTP_AUTH=off \
  SMTP_USER= \
  SMTP_PASS= \
  SMTP_FROM=noreply@example.com

RUN echo Europe/Paris | tee /etc/timezone \
 && apt-get update \
 && apt-get install -y software-properties-common python-software-properties curl \
 && add-apt-repository -y ppa:ondrej/php \
 && apt-get update \
 && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
 && apt-get install -y --no-install-recommends --allow-unauthenticated apache2 php7.1 libapache2-mod-php7.1 php-memcached \
      php7.1-mcrypt php7.1-mbstring php7.1-xml php7.1-mysql php7.1-opcache php7.1-json \
      php7.1-gd php7.1-curl php7.1-ldap php7.1-mysql php7.1-odbc php-7.1-bcmath php7.1-soap php7.1-xsl \
      php7.1-zip php7.1-intl php7.1-cli php7.1-xdebug \
      nodejs rsync \
      build-essential \
      unzip git-core ssh curl mysql-client nano vim less \
      msmtp msmtp-mta telnet \
 && rm -Rf /var/cache/apt/* \
 && systemctl disable apache2 \
 && a2enmod rewrite expires \
 && phpenmod bcmath \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer \
 && echo 'export PATH="$PATH:/var/www/vendor/bin"' >> ~/.bashrc \
 && npm install -g grunt-cli \
 && sed -i 's/\/var\/www\/html/\/var\/www\/web/g' /etc/apache2/sites-enabled/000-default.conf \
 && composer global require drush/drush:8.* \
 && ln -s /root/.composer/vendor/bin/drush /usr/bin/drush \
 && phpdismod xdebug \
 && drush dl drush_language-8.x \
 && mkdir -p /var/scripts \
 && cd /var/scripts \
 && curl -O http://get.sensiolabs.org/security-checker.phar

COPY config/php.ini /etc/php/7.1/apache2/php.ini
COPY config/apache2.conf /etc/apache2/apache2.conf
COPY config/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
COPY config/scripts /var/scripts

LABEL cron="drush cron" \
      update="sh /var/scripts/update.sh" \
      securityupdates="sh /var/scripts/securityupdates.sh" \
      restore="sh /var/scripts/restore.sh" \
      backup="sh /var/scripts/backup.sh" \
      test="sh /var/scripts/test.sh"

WORKDIR /var/www/web

CMD ["/var/scripts/startup.sh"]
