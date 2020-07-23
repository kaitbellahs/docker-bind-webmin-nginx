FROM ubuntu:focal AS add-apt-repositories

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install apt-utils \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
    && DEBIAN_FRONTEND=noninteractive apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

FROM ubuntu:focal

LABEL maintainer="Khalid Ait Bellahs <kaitbellahs@gmail.com>"

ENV BIND_USER=bind \
    NGINX_USER=www-data \
    DATA_DIR=/data

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9 bind9-host dnsutils \
      webmin \
      nginx \
      nginx-extras \
    && rm -rf /var/lib/apt/lists/* \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp 80/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
