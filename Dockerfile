FROM picorb/rabbitmq-base:ubuntu

MAINTAINER Hiroaki Sano <hiroaki.sano.9stories@gmail.com>

# Redis
#ADD files/sensu.repo /etc/yum.repos.d/
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
RUN echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
RUN apt-get update
RUN apt-get install -y \
    redis-server \
    make \
    automake autoconf \
    curl openssl sqlite libevent-dev python-dev \
    ruby ruby-dev build-essential rubygems-integration
RUN apt-get install -y sensu uchiwa

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
ADD files/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py && \
    easy_install virtualenv supervisor pip argparse sensu-plugin sh walrus requests==2.5.3 locustio && \
    pip install pyzmq gevent-zeromq
RUN virtualenv /env
ADD files/supervisord.conf /etc/supervisord.conf
ADD run.sh /tmp/sensu-run.sh
RUN chmod +x /tmp/sensu-run.sh

EXPOSE 3000 4369 4567 5672 5671 15672

CMD ["/tmp/sensu-run.sh"]
