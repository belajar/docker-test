#this postgres docker is running on debian
FROM ubuntu:16.04
MAINTAINER Faizal Abdul Manan <faizal.manan@canang.com.my>

#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -q update
RUN apt-get -y -q install build-essential python-software-properties software-properties-common wget curl git fontconfig rpm vim

# Java 1.8
RUN apt-get -y -q install openjdk-8-jdk git

# maven
RUN apt-get -y -q install maven

# ssh private key
ADD id_rsa  /root/.ssh/id_rsa
ADD known_hosts /root/.ssh/known_hosts
RUN chown -R root:root /root/.ssh
RUN chmod 700 ~/.ssh
RUN chmod 600 ~/.ssh/id_rsa

# postgresql
RUN apt-get -y -q install postgresql-9.5 postgresql-contrib-9.5

ENV PGDATA /etc/postgresql/9.5/main
ENV LOGDIR  /etc/postgresql/9.5/main/postgresql.log
RUN chown -R postgres:postgres /etc/postgresql
RUN chown -R postgres:postgres /var/run/postgresql
RUN ln -s /tmp/.s.PGSQL.5432 /var/run/postgresql/.s.PGSQL.5432
WORKDIR /usr/lib/postgresql/9.5/bin

USER postgres
RUN mkdir /var/run/postgresql/9.5-main.pg_stat_tmp/
RUN sed -e '90d' -i /etc/postgresql/9.5/main/pg_hba.conf
RUN sed -e '91d' -i /etc/postgresql/9.5/main/pg_hba.conf

RUN echo "host all all 0.0.0.0/0 md5" >> '/etc/postgresql/9.5/main/pg_hba.conf'
RUN echo "local all all trust" >> '/etc/postgresql/9.5/main/pg_hba.conf'
RUN echo "listen_addresses='*'" >> '/etc/postgresql/9.5/main/postgresql.conf'
RUN /etc/init.d/postgresql start 
EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]
USER root

RUN mkdir ~/docker/
COPY entrypoint.sh /root/docker/
RUN chown -R root:root /root/docker/
RUN chmod +x /root/docker/entrypoint.sh
CMD ["/root/docker/entrypoint.sh"]

