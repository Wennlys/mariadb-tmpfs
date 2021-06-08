FROM alpine:latest

ENV TMPFS_SIZE 4000
ENV TMPFS_DIR /opt/tmpfs

RUN apk update

RUN apk add --no-cache mariadb mariadb-client pwgen psmisc bc openssh && \
    rm -f /var/cache/apk/*

COPY my.cnf /etc/mysql/my.cnf
RUN mkdir /docker-entrypoint-initdb.d && \
    mkdir /scripts && \
    mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

RUN mkdir /var/run/sshd
RUN echo 'root:test' | chpasswd
RUN sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 22

RUN mkdir -p /opt/tmpfs
RUN chown mysql: /opt/tmpfs -R
RUN mkdir -p /opt/backup
RUN chown mysql: /opt/backup -R

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["sh", "entrypoint.sh"]