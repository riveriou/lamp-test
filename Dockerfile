FROM ubuntu:latest
MAINTAINER River riou

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV ACCEPT_EULA N
ENV MSSQL_PID standard
ENV MSSQL_SA_PASSWORD sasa
ENV MSSQL_TCP_PORT 1433
RUN ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone

WORKDIR /data
ADD . /data
RUN chmod 755 /data/install.sh
RUN /data/install.sh
RUN mv /data/test.php /www
RUN rm -r /data/*

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
VOLUME [ "/var/log/mysql/", "/var/log/apache2/" ]

EXPOSE 1433
EXPOSE 80

# write a startup script
RUN echo '/opt/mssql/bin/sqlservr' >> /startup.sh
RUN echo '/opt/lampp/lampp start' >> /startup.sh
RUN echo '/usr/bin/supervisord -n' >> /startup.sh
RUN echo "set pastetoggle=<F11> " >> ~/.vimrc


CMD ["sh", "/startup.sh"]
