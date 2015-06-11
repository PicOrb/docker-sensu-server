#!/usr/bin/python
from sensu_plugin import SensuPluginMetricStatsd

class FooBarBazMetricStatsd(SensuPluginMetricStatsd):
    def run(self):
        self.output('sample', 1, 'ms')
        self.ok()

if __name__ == "__main__":
    f = FooBarBazMetricStatsd()
