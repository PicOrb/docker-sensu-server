FROM picorb/rabbitmq-base

MAINTAINER Hiroaki Sano <hiroaki.sano.9stories@gmail.com>

# Redis
RUN yum install -y \
    redis \
    sensu uchiwa
    gcc g++ make \
    automake autoconf \
    curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel \
    ruby ruby-dev build-essential ruby-rdoc ruby-devel rubygems

# Sensu server
ADD ./files/sensu.repo /etc/yum.repos.d/
ADD ./files/config.json /etc/sensu/
RUN gem install sensu-plugin --no-rdoc --no-ri && \
    mkdir -p /etc/sensu/ssl && \
    cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem && \
    cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
ADD ./files/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py && \
    easy_install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

EXPOSE 3000 4369 4567 5672 5671 15672

CMD ["/usr/bin/supervisord"]
