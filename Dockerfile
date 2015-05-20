FROM picorb/rabbitmq-base

MAINTAINER Hiroaki Sano <hiroaki.sano.9stories@gmail.com>

# Redis
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
ADD ./files/sensu.repo /etc/yum.repos.d/
RUN yum --enablerepo=remi,remi-test install -y \
    redis \
    gcc g++ make \
    automake autoconf \
    curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel libevent-devel python-devel \
    ruby ruby-dev build-essential ruby-rdoc ruby-devel rubygems
RUN yum install -y sensu uchiwa

# Sensu server
#ADD ./files/config.json /etc/sensu/
RUN /usr/bin/gem install sensu-plugin --no-rdoc --no-ri && \
    mkdir -p /etc/sensu/ssl && \
    cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem && \
    cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem
    
RUN rm -rf /etc/sensu/plugins && \
    git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins && \
    cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/ && \
    find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

# uchiwa
ADD ./files/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py && \
    easy_install supervisor argparse sensu-plugin sh walrus requests==2.5.3 locustio
ADD files/supervisord.conf /etc/supervisord.conf
ADD run.sh /tmp/sensu-run.sh
RUN chmod +x /tmp/sensu-run.sh

EXPOSE 3000 4369 4567 5672 5671 15672

CMD ["/tmp/sensu-run.sh"]
