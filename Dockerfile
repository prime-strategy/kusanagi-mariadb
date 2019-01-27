FROM mariadb:10.4.1-bionic

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/* \
    \
    && wget -O /usr/local/bin/peer-finder https://storage.googleapis.com/kubernetes-release/pets/peer-finder \
    && chmod +x /usr/local/bin/peer-finder \
    && mkdir -p /etc/mysql/my.cnf.d \
    && :

COPY files/galera-recovery.sh /usr/local/bin
COPY files/on-start.sh /usr/local/bin
COPY files/my.cnf /etc/mysql/
COPY files/galera.cnf.template /etc/mysql/my.cnf.d/
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/on-start.sh /usr/local/bin/galera-recovery.sh

ARG MICROSCANNER_TOKEN
RUN [ x${MICROSCANNER_TOKEN} != x ] \
	&& update-ca-certificates \
	&& wget --no-check-certificate https://get.aquasec.com/microscanner \
	&& chmod +x microscanner \
	&& ./microscanner ${MICROSCANNER_TOKEN} || exit 1\
	&& rm ./microscanner

RUN apt-get purge -y --auto-remove ca-certificates wget 

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]
