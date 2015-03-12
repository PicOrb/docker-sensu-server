FROM picorb/rabbitmq-base

MAINTAINER Hiroaki Sano <hiroaki.sano.9stories@gmail.com>

# Redis
RUN yum install -y redis

# Sensu server
ADD ./files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
ADD ./files/config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl
RUN cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem
RUN cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
RUN yum install -y uchiwa
ADD ./files/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py
RUN easy_install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

EXPOSE 3000 4369 4567 5672 5671 15672

CMD ["/usr/bin/supervisord"]