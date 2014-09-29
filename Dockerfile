FROM ubuntu:trusty

MAINTAINER Vasan <vasan.srini@gmail.com>

# Dockerfile based from https://github.com/tutumcloud/tutum-docker-php
# Modified to include magento dependencies

ENV MAGENTO_SAMPLE_VER 1.9.0.0

#
# Installations: time consuming. Do these first.
#

# 1. Install packages: apache, php, php modules pre-req for magento
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -yq install \
       	curl \
	mysql-client \
       	apache2 \
       	libapache2-mod-php5 \
       	php5-mysql \
       	php5-gd \
       	php5-curl \
       	php-pear \
       	php5-mcrypt \
       	php5-mhash \
       	php-soap \
       	php-apc \
&& rm -rf /var/lib/apt/lists/*

# 2. Install magento program files, replace /var/www/html contents completely
# This is relatively small, 22M compressed, maybe 50M uncompressed
ADD magento.tar.gz /var/www/
# we'll have a directory called magento under /var/www/
# rename this to magento-sample-data-x.x.x.x so that we can untar the
# sample data directly int this.
RUN mv /var/www/magento /var/www/magento-sample-data-$MAGENTO_SAMPLE_VER

# now untar the sample data "in-place"
ADD magento-sample-data.tar.gz /var/www/

# now rename it to html, which is what is expected.
# Also set ownership and permissions as required by magento.
RUN rm -rf /var/www/html \
	&& mv /var/www/magento-sample-data-$MAGENTO_SAMPLE_VER /var/www/html \
	&& chown -R www-data:www-data /var/www/html \
	&& find /var/www/html -type d -exec chmod 700 {} \; \
	&& find /var/www/html -type f -exec chmod 600 {} \;

#
# Configure stuff: not so time / space consuming.
#

# todo: what's this?
RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

# set up php5enmod: required for these php modules, otherwise they don't get anabled.
RUN php5enmod mcrypt
RUN a2enmod rewrite

# prepare to the future... (todo ... )
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# For AllowOverrides that magento needs
ADD magento.conf /etc/apache2/conf-available/magento.conf
RUN ln -s ../conf-available/magento.conf /etc/apache2/conf-enabled/magento.conf

# add a sample php file to test if php is working. 
# ADD heartbeat.php /var/www/html/heartbeat.php

#
# Setup the image and startup
#

# Add startup scripts
ADD initialize.sh /initialize.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# wrap up
EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/initialize.sh"]
CMD ["/run.sh"]

