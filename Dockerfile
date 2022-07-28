#==============#
# imagem final #
#==============#
FROM ubuntu:20.04

ARG WWWGROUP

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
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

RUN apt-get install -y \
    git \
    supervisor \
    vim \
    apache2

RUN apt-get install -y \
    net-tools \
    traceroute \
    telnet

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php

#instalando o ODBC para SQL Server
#https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#ubuntu17
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get -my install msodbcsql17
RUN ACCEPT_EULA=Y apt-get -my install mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

RUN apt-get update

RUN apt-get install -y \
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

# adicionando extensões à partir do PECL
RUN pecl update-channels

RUN pecl -d php_suffix=8.0 install -f sqlsrv pdo_sqlsrv

RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini && \
  printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini

RUN phpenmod -v ALL -s ALL sqlsrv pdo_sqlsrv

RUN echo 'alias php8=/usr/bin/php8.0' >> ~/.bashrc

# instalar composer a partir do outro container
COPY --from=composer:2.3.10 /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod proxy_ajp \
    && a2enmod proxy_fcgi \
    && a2enmod ssl \
    && a2enmod deflate \
    && a2enmod headers \
    && a2enmod proxy_balancer \
    && a2enmod proxy_connect \
    && a2enmod proxy_html \
    && a2enmod setenvif

RUN mkdir -p /run/php

# copiando configs do apache
COPY config/apache/ports.conf /etc/apache2/ports.conf
COPY config/apache/vhost-000-default.conf /etc/apache2/sites-enabled/000-default.conf

# copiando config do supervisor
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/supervisor/viware.conf /etc/supervisor/conf.d/viware.conf

# PHP FPM
COPY config/fpm/pool_80.conf /etc/php/8.0/fpm/pool.d/pool_80.conf

# criando diretório para armazenar a chave ssh
RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh

# aceitar a chave do servidor Azure
RUN ssh-keyscan -H ssh.dev.azure.com > /root/.ssh/known_hosts

RUN apt purge -y \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    unixodbc-dev \
    build-essential \
    php8.0-dev

# Clean up
RUN apt-get -y autoremove \
    && apt-get clean \
    && apt clean \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

ENTRYPOINT ["supervisord"]