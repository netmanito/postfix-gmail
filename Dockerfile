# Dockerfile for Postfix-Gmail

# Build with:
# docker build -t postfix:v0 .

# Run with:
# docker run -it postfix:v0 

FROM phusion/baseimage
MAINTAINER jacinto calvo http://seriousman.org
ENV REFRESHED_AT 2017-12-21

###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites (cURL, gosu, JDK)

ENV GOSU_VERSION 1.8

ARG DEBIAN_FRONTEND=noninteractive
RUN set -x \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ca-certificates curl git vim net-tools inetutils-ping netcat rsyslog \
 && rm -rf /var/lib/apt/lists/* \
 && curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
 && curl -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && apt-get update -qq \
 && apt-get install -qqy postfix mailutils libsasl2-2 ca-certificates libsasl2-modules \ 
 && apt-get clean \
 && set +x

###############################################################################
#                               CONFIGURATION
###############################################################################

ENV USERNAME="gmail_username"
ENV PASSWORD="gmail_password"

### Install Postfix gmail-smtp
RUN rm -rf /etc/postfix/main.cf
ADD ./main.cf  /etc/postfix/main.cf
ADD ./sasl_passwd /etc/postfix/sasl/passwd
RUN sed -i -e 's#${USERNAME}#'$USERNAME'#' /etc/postfix/sasl/passwd \
 && sed -i -e 's#${PASSWORD}#'$PASSWORD'#' /etc/postfix/sasl/passwd \
 && postmap /etc/postfix/sasl/passwd
RUN chmod 600 /etc/postfix/sasl/passwd
ADD ./generic /etc/postfix/generic
RUN sed -i -e 's#${USERNAME}#'$USERNAME'#' /etc/postfix/generic \
 && postmap /etc/postfix/generic
RUN chmod 600 /etc/postfix/sasl/passwd

###############################################################################
#                                   START
###############################################################################
ADD ./start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 25 587

CMD [ "/root/start.sh" ]
