#!/bin/sh
DASHBOARD_USER=${DASHBOARD_USER:-admin}
DASHBOARD_PASS=${DASHBOARD_PASS:-sensu}
SENSU_HOST=${SENSU_HOST:-localhost}
RABBITMQ_HOST=${RABBITMQ_HOST:-localhost}
REDIS_HOST=${REDIS_HOST:-localhost}
SKIP_CONFIG=${SKIP_CONFIG:-}
SENSU_CONFIG_URL=${SENSU_CONFIG_URL:-}
SENSU_CLIENT_CONFIG_URL=${SENSU_CLIENT_CONFIG_URL:-}
SENSU_CHECKS_CONFIG_URL=${SENSU_CHECKS_CONFIG_URL:-}

if [ ! -z "$SENSU_CONFIG_URL" ] ; then
    wget --no-check-certificate -O /etc/sensu/config.json $SENSU_CONFIG_URL
else
    if [ ! -e "/etc/sensu/config.json" ] ; then
        cat << EOF > /etc/sensu/config.json
{
  "rabbitmq": {
    "port": 5671,
    "host": "$RABBITMQ_HOST",
    "user": "sensu",
    "password": "password",
    "vhost": "/sensu",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  },
  "redis": {
    "host": "$REDIS_HOST",
    "port": 6379
  },
  "api": {
    "host": "$SENSU_HOST",
    "bind": "0.0.0.0",
    "port": 4567
  },
  "dashboard": {
    "host": "$SENSU_HOST",
    "port": 8080,
    "user": "$DASHBOARD_USER",
    "password": "$DASHBOARD_PASS"
  },
  "handlers": {
    "graphite": {
      "type": "udp",
      "socket": {
        "host": "grafana",
        "port": 8125
      },
      "mutator": "only_check_output"
    },
    "default": {
      "type": "pipe",
      "command": "true"
    }
  }
}

EOF
    fi
fi

if [ ! -z "$SENSU_CLIENT_CONFIG_URL" ] ; then
    wget --no-check-certificate -O /etc/sensu/conf.d/client.json $SENSU_CLIENT_CONFIG_URL
else
    if [ ! -e "/etc/sensu/conf.d/client.json" ] ; then
    cat << EOF > /etc/sensu/conf.d/client.json
{
    "client": {
      "name": "sensu-server",
      "address": "localhost",
      "subscriptions": [ "default", "common", "sensu" ]
    },
   "keepalive": {
     "thresholds": {
       "critical": 60
     },
     "refresh": 300
   }
}
EOF
    fi
fi

rm /etc/default/sensu
if [ ! -z "$SENSU_CLIENT_INIT_CONFIG_URL" ] ; then
    wget --no-check-certificate -O /etc/default/sensu $SENSU_CLIENT_INIT_CONFIG_URL
else
    cat << EOF > /etc/default/sensu
EMBEDDED_RUBY=true
EOF
fi

if [ ! -z "$SENSU_CHECKS_CONFIG_URL" ] ; then
    wget --no-check-certificate -O /etc/sensu/conf.d/checks.json $SENSU_CHECKS_CONFIG_URL
else
    if [ ! -e "/etc/sensu/conf.d/checks.json" ] ; then
    	cat << EOF > /etc/sensu/conf.d/checks.json
{
  "checks": {
    "sensu-rabbitmq-beam": {
      "handlers": [
        "default"
      ],
      "command": "/etc/sensu/plugins/processes/check-procs.rb -p beam -C 1 -w 4 -c 5",
      "interval": 60,
      "occurrences": 2,
      "refresh": 300,
      "subscribers": [ "sensu" ]
    },
    "sensu-rabbitmq-epmd": {
      "handlers": [
        "default"
      ],
      "command": "/etc/sensu/plugins/processes/check-procs.rb -p epmd -C 1 -w 1 -c 1",
      "interval": 60,
      "occurrences": 2,
      "refresh": 300,
      "subscribers": [ "sensu" ]
    },
    "sensu-redis": {
      "handlers": [
        "default"
      ],
      "command": "/etc/sensu/plugins/processes/check-procs.rb -p redis-server -C 1 -w 4 -c 5",
      "interval": 60,
      "occurrences": 2,
      "refresh": 300,
      "subscribers": [ "sensu" ]
    },
    "sensu-api": {
      "handlers": [
        "default"
      ],
      "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-api -C 1 -w 4 -c 5",
      "interval": 60,
      "occurrences": 2,
      "refresh": 300,
      "subscribers": [ "sensu" ]
    },
    "sensu-dashboard": {
      "handlers": [
        "default"
      ],
      "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-dashboard -C 1 -w 1 -c 1",
      "interval": 60,
      "occurrences": 2,
      "refresh": 300,
      "subscribers": [ "sensu" ]
    }
  }
}
EOF
  fi
fi

/etc/init.d/uchiwa start
/usr/local/bin/supervisord
