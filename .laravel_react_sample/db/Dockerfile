# FROM --platform=linux/x86_64 mysql:8.0.30
FROM --platform=linux/x86_64 mariadb:latest

# mariadbの場合はアンコメント
COPY ./50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chown 644 /etc/mysql/mariadb.conf.d/50-server.cnf

# mysqlの場合はアンコメント
# COPY ./my.cnf /etc/mysql/conf.d/my.cnf
# RUN chown 644 /etc/mysql/conf.d/my.cnf
