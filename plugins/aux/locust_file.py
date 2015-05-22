import json
from sh import curl
from locust import HttpLocust, TaskSet
import warnings
from requests.packages.urllib3 import exceptions

def login(l):
    #login = l.client.post("/iam/v1/authenticate", {"username":"2A6B0U16535H6X0D5822", "password":'$2a$12$WB8KmRcUnGpf1M6oEdLBe.GrfBEaa94U4QMBTPMuVWktWZf91AJk'})
    token_curl = curl('https://{0}/iam/v1/authenticate'.format('ecepeda-api.route105.net'), '-s', '-k', '-X', 'POST', '-H', 'Accept: application/json', '--user', '2A6B0U16535H6X0D5822:$2a$12$WB8KmRcUnGpf1M6oEdLBe.GrfBEaa94U4QMBTPMuVWktWZf91AJk')
    return json.loads(str(token_curl))['authentication']['token']

def remediations(l):
    headers = {'X-Iam-Auth-Token': l.token, 'X-Request-Id': 'DEADBEEF'}
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", exceptions.InsecureRequestWarning)
        l.client.get("/assets/v1/67000001/environments/814C2911-09BB-1005-9916-7831C1BAC182/remediations", headers=headers, verify=False)

def profile(l):
    l.client.get("/profile")

class UserBehavior(TaskSet):
    tasks = {remediations:2}

    def on_start(self):
        self.token = login(self)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait=50
    max_wait=90
