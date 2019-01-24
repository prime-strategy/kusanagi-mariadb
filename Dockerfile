FROM mariadb:10.4.1-bionic

RUN set -x && \
    apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && \
    rm -rf /var/lib/apt/lists/* && \
    \
    wget -O /usr/local/bin/peer-finder https://storage.googleapis.com/kubernetes-release/pets/peer-finder && \
    chmod +x /usr/local/bin/peer-finder && \
    \
    apt-get purge -y --auto-remove ca-certificates wget

COPY files/galera-recovery.sh /usr/local/bin
COPY files/on-start.sh /usr/local/bin
COPY files/my.cnf /etc/mysql/
COPY files/galera.cnf.template /etc/mysql/my.cnf.d

RUN chmod +x /usr/local/bin/on-start.sh /usr/local/bin/galera-recovery.sh

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]
