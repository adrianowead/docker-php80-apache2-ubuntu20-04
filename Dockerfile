#==============#
# imagem final #
#==============#
FROM ubuntu:20.04

ARG WWWGROUP

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /var/www/html

COPY installer.sh /var/www/html

RUN chmod +x ./installer.sh

RUN ./installer.sh

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

RUN apt-get update

RUN apt-get install -y \
    openssh-client

# criando diretório para armazenar a chave ssh
RUN mkdir -p /root/.ssh \
    && chmod 0700 /root/.ssh

# aceitar a chave do servidor Azure
RUN ssh-keyscan -H ssh.dev.azure.com > /root/.ssh/known_hosts

RUN apt purge -y \
    ca-certificates \
    lsb-release \
    apt-transport-https

RUN apt-get -y autoremove \
    && apt-get clean \
    && apt clean \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

ENTRYPOINT ["supervisord"]