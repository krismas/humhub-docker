# Humhub on Turnkeylinux

FROM cboulanger/turnkeylinux-lamp:v14.0
MAINTAINER Ackwa "info@ackwa.fr"

ENV DEBIAN_FRONTEND noninteractive

# Updates & packages install

RUN apt-get install -y -q php5-gd php5-curl php5-sqlite php5-ldap php5-intl php-apc wget cron

ENV HUMHUB_VERSION 1.0.0-beta.3
ENV HUMHUB_DIR_NAME humhub-$HUMHUB_VERSION
ENV HUMHUB_DOWNLOAD_URL http://downloads.sourceforge.net/project/humhub/$HUMHUB_DIR_NAME.tar.gz

RUN rm -rf /var/www/*
RUN wget -q $HUMHUB_DOWNLOAD_URL
RUN tar -xzf $HUMHUB_DIR_NAME.tar.gz && rm $HUMHUB_DIR_NAME.tar.gz
RUN mv $HUMHUB_DIR_NAME /var/www/humhub
RUN chown www-data:www-data -R /var/www

# PHP config

ENV POST_MAX_SIZE 20M
ENV UPLOAD_MAX_FILESIZE 10M
ENV MEMORY_LIMIT 128M

RUN sed -i -e "s/^post_max_size\s*=.*/post_max_size = $POST_MAX_SIZE/" \
           -e "s/^upload_max_filesize\s*=.*/upload_max_filesize = $UPLOAD_MAX_FILESIZE/" \
           -e "s/^memory_limit\s*=.*/memory_limit = $MEMORY_LIMIT/" /etc/php5/apache2/php.ini

# Apache config

ADD pre-conf.sh /pre-conf.sh
RUN chmod 750 /pre-conf.sh
RUN (/bin/bash -c /pre-conf.sh)
RUN service apache2 stop
RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2dismod status
RUN a2dissite default-ssl
RUN a2dissite 000-default

ADD humhub-ssl.conf /etc/apache2/sites-available/humhub-ssl.conf
RUN a2ensite humhub-ssl.conf

# Import existing data for importing (optional)

ADD humhub-data /humhub-data
ADD import.sh /import.sh
RUN chmod 750 /import.sh
RUN (/bin/bash -c /import.sh)

# Add export script for migrating data to a different container

ADD export.sh /export.sh
RUN chmod 750 /export.sh

# Supervisor

ADD supervisor-humhub.conf /etc/supervisor/conf.d/supervisor-humhub.conf