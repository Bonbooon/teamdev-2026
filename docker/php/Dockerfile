FROM php:8.3-fpm

# php.iniをコピー
COPY php.ini /usr/local/etc/php/

# Xdebug設定をコピー
ADD setup/xdebug.ini /tmp/xdebug.ini

# 必要なパッケージをインストール
RUN apt-get update \
  && apt-get install -y libzip-dev zlib1g-dev unzip libpq-dev \
  libjpeg62-turbo-dev libwebp-dev libpng-dev \
  && docker-php-ext-configure gd --with-jpeg --with-webp \
  && docker-php-ext-install zip sockets pdo_pgsql gd \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && apt-get clean

# Composer 2.0をインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer self-update --2
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# 作業ディレクトリ
WORKDIR /work/web
