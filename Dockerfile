FROM php:7.4-fpm

ARG DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR "/var/www"

# Install dependencies
RUN set -xe; \
    apt-get update; \
    apt-get -y install make nano git openssh-client openssh-server; \
    apt-get -y --no-install-recommends install g++ zlib1g-dev libpq-dev libpng-dev libjpeg-dev libzip-dev libfreetype6-dev automake libtool libonig-dev; \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/
RUN docker-php-ext-install mbstring zip exif pcntl gd
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/

# change permission
RUN chmod 755 /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
