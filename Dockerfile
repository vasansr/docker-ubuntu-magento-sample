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

# 2. Install magento program files, replace /var/www/html contents completely
# This is relatively small, 22M compressed, maybe 50M uncompressed
RUN rm -rf /var/www/html \
	&& curl http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz \
	| tar -xz -C /var/www \
	&& mv /var/www/magento /var/www/html

# 3. Install magento sample files: this is much bigger, about 600M uncompressed
RUN curl http://www.magentocommerce.com/downloads/assets/1.9.0.0/magento-sample-data-1.9.0.0.tar.gz\
	| tar -xz -C /var/www/html --overwrite 

# 4. Set permissions for magento and sample files
RUN chown -R www-data:www-data /var/www/html
RUN find /var/www/html -type d -exec chmod 700 {} \;
RUN find /var/www/html -type f -exec chmod 600 {} \;

#
# Configure stuff
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

# Add startup scripts
ADD initialize.sh /initialize.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# wrap up
EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/initialize.sh"]
CMD ["/run.sh"]

