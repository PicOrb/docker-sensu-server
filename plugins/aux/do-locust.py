#!/usr/bin/python
from sensu_plugin import SensuPluginMetricJSON
import requests
import os
import json
from subprocess import Popen, PIPE
from sh import Command
from walrus import *
#from redis import *
import math
from requests.auth import HTTPBasicAuth

class FooBarBazMetricJSON(SensuPluginMetricJSON):
    def run(self):
        api = 'ecepeda-api.route105.net'
        path = os.path.dirname(os.path.realpath(__file__))
        command, error = Popen(['locust', '-f', '{0}/locust_file.py'.format(path), '-L', 'INFO', '--no-web', '--host', 'https://{0}'.format(api), '--only-summary', '--print-stats', '-n', '100'], stdin=PIPE, stdout=PIPE, stderr=PIPE).communicate()
        command = re.sub("\[(.*?)/INFO/(.*?)\n","",command + error)
        self.warning(command)

if __name__ == "__main__":
    f = FooBarBazMetricJSON()
