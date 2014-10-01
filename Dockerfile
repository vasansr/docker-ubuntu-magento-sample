FROM ubuntu:trusty

MAINTAINER Vasan <vasan.srini@gmail.com>

# Dockerfile based from https://github.com/tutumcloud/tutum-docker-php
# Modified to include magento dependencies

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

#
# The following source files are not checked in, we need to download and construct
# them as per the script get-magento.sh
#
COPY magento/ /var/www/html/
COPY magento-sample-data-1.9.0.0/magento_sample_data_for_1.9.0.0.sql /

# The following adds another 600 Mb to the image size. Better do it after launching
# the container (see initialize.sh).
# RUN chown -R www-data:www-data /var/www/html && chmod -R go-rwX /var/www/html

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
EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/initialize.sh"]
CMD ["/run.sh"]

# Add startup scripts
ADD initialize.sh /initialize.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

