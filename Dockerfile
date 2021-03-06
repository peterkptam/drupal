# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.0-apache

RUN a2enmod rewrite

# install the PHP extensions we need - and vim for drush settings.php editing
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev vim \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 8.2.6
ENV DRUPAL_MD5 57526a827771ea8a06db1792f1602a85

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes \
	&& chown www-data:www-data /var/www/html

#Pull down drush
RUN curl -fSL "http://files.drush.org/drush.phar" -o /usr/local/bin/drush

#Make drush executable
RUN chmod +x /usr/local/bin/drush

#Define data volumes
VOLUME ["/var/www/html"]
