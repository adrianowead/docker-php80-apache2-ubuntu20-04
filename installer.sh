#!/bin/bash

apt-get update

apt-get install -y \
    curl \
    ca-certificates \
    zip \
    unzip \
    wget \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    unixodbc \
    unixodbc-dev \
    build-essential \
    freetds-common \
    libsybdb5

apt-get install -y \
    git \
    supervisor \
    vim \
    apache2

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

#instalando o ODBC para SQL Server
#https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#ubuntu17
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

apt-get update && \
    ACCEPT_EULA=Y apt-get -my install msodbcsql17

ACCEPT_EULA=Y apt-get -my install mssql-tools

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

/bin/bash -c "source ~/.bashrc"

apt-get update



apt-get install -y \
    php8.0 \
    php8.0-dev \
    php8.0-fpm \
    php8.0-pgsql \
    php8.0-imap \
    php8.0-bcmath \
    php8.0-ldap \
    php8.0-xdebug \
    php8.0-decimal \
    php8.0-gd \
    php8.0-gmp \
    php8.0-grpc \
    php8.0-imagick \
    php8.0-inotify \
    php8.0-memcache \
    php8.0-memcached \
    php8.0-msgpack \
    php8.0-mysql \
    php8.0-mysqlnd \
    php8.0-oauth \
    php8.0-odbc \
    php8.0-opcache \
    php8.0-pcov \
    php8.0-protobuf \
    php8.0-raphf \
    php8.0-readline \
    php8.0-redis \
    php8.0-soap \
    php8.0-sqlite3 \
    php8.0-xml \
    php8.0-xmlrpc \
    php8.0-yaml \
    php8.0-zmq \
    php8.0-curl \
    php8.0-intl \
    php8.0-decimal \
    php8.0-igbinary \
    php8.0-mbstring \
    php8.0-mcrypt \
    php8.0-mongodb \
    php8.0-psr \
    php8.0-swoole \
    php8.0-uuid \
    php8.0-xsl \
    php8.0-zip \
    php8.0-zstd

pecl update-channels

pecl -d php_suffix=8.0 install -f sqlsrv pdo_sqlsrv

printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini && \
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini

phpenmod -v ALL -s ALL sqlsrv pdo_sqlsrv



apt purge -y \
    software-properties-common \
    unixodbc-dev \
    build-essential \
    php8.0-dev \
    git


apt-get -y autoremove \
    && apt-get clean \
    && apt clean \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*