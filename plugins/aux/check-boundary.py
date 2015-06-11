#!/usr/bin/python
from sensu_plugin import SensuPluginMetricJSON
import requests
#import os
import json
from sh import curl
from walrus import *
#from redis import *
import math
#from requests.auth import HTTPBasicAuth
import statsd
import warnings
from requests.packages.urllib3 import exceptions

db = Database(host='localhost', port=6379, db=0)
c = statsd.StatsClient('grafana', 8125)

class FooBarBazMetricJSON(SensuPluginMetricJSON):
    def run(self):
        endpoints = ['topology', 'remediations']
        positions = [30, 50, 99]

        api = 'ecepeda-api.route105.net'

        token_curl = curl('https://{0}/aims/v1/authenticate'.format(api), '-s', '-k', '-X', 'POST', '-H', 'Accept: application/json', '--user', '2A6B0U16535H6X0D5822:$2a$12$WB8KmRcUnGpf1M6oEdLBe.GrfBEaa94U4QMBTPMuVWktWZf91AJk')
        headers = {'X-Iam-Auth-Token': json.loads(str(token_curl))['authentication']['token'], 'X-Request-Id': 'DEADBEEF'}

        for endpoint in endpoints:
            a = db.ZSet('measures_{0}'.format(endpoint))
            percentiles = db.Hash('percentiles_{0}'.format(endpoint))
            current = percentiles['current']
            if current is None or int(current) > 99:
                current = 1

            url = 'https://{0}/assets/v1/67000001/environments/814C2911-09BB-1005-9916-7831C1BAC182/{1}'.format(api, endpoint)

            with warnings.catch_warnings():
                warnings.simplefilter("ignore", exceptions.InsecureRequestWarning)
                r = requests.get(url, headers=headers, verify=False)
            a.remove(current)
            a.add(current, r.elapsed.microseconds)
            c.timing(endpoint, int(r.elapsed.microseconds)/1000)
            iterate = True
            elements = []
            iterator = a.__iter__()
            while iterate:
                try:
                    elem = iterator.next()
                    elements.append({'position': elem[0], 'time': elem[1]})
                except:
                    iterate = False
            if len(elements) > 0:
                for percentile in positions:
                    position = (percentile*.01) * len(elements) - 1
                    percentiles[percentile] = elements[int(math.ceil(position))]

            percentiles['current'] = int(current) + 1
            self.output(str(percentiles))
        self.warning(str(endpoints))

if __name__ == "__main__":
    f = FooBarBazMetricJSON()
