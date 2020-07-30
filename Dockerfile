FROM ubuntu:latest
MAINTAINER River riou

ENV DEBIAN_FRONTEND noninteractive

RUN ln -snf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && echo Asia/Taipei > /etc/timezone

WORKDIR /data
ADD . /data
RUN chmod 755 /data/phpmysql.sh
RUN /data/phpmysql.sh
RUN rm /data/phpmysql.sh 
RUN mv /data/test.php /var/www/html/

RUN apt-get install -y supervisor
RUN apt-get clean

RUN echo "[supervisord] " >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo "user=root" >> /etc/supervisor/conf.d/supervisord.conf

RUN echo "[program:apache2]" >> /etc/supervisor/conf.d/supervisord.conf
RUN echo 'command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"' >> /etc/supervisor/conf.d/supervisord.conf

RUN echo '#!/bin/sh' >> /startup.sh
RUN echo 'service apache2 restart' >> /startup.sh
RUN echo 'exec supervisord -c /etc/supervisor/supervisord.conf' >> /startup.sh

RUN chmod +x /startup.sh

EXPOSE  80
CMD ["/startup.sh"]
