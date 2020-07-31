FROM ubuntu:latest
MAINTAINER River riou

ENV DEBIAN_FRONTEND noninteractive

RUN ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone

WORKDIR /data
ADD . /data
RUN chmod 755 /data/install.sh
RUN /data/install.sh
RUN rm /data/install.sh 
RUN mv /data/test.php /www

RUN apt-get clean
VOLUME [ "/var/log/mysql/", "/var/log/apache2/" ]

EXPOSE 3306
EXPOSE 22
EXPOSE 80

# write a startup script
RUN echo '/opt/lampp/lampp start' >> /startup.sh
RUN echo '/usr/bin/supervisord -n' >> /startup.sh

CMD ["sh", "/startup.sh"]
