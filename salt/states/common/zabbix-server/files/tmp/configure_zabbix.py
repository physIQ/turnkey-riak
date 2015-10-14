#!/usr/bin/env python

from pyzabbix import ZabbixAPI, ZabbixAPIException
import socket
import sys
import os
from collections import defaultdict

grouplist = ('LOGGING','RIAK','HAPROXY')
td = {}
gd = {}

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = 'http://127.0.0.1/zabbix'

# Local system hostname
hostname=socket.gethostname()

zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify = False

# Login to the Zabbix API
try:
	zapi.login('Admin', 'zabbix')
except ZabbixAPIException as e:
        print(e)
	# Must already be configured, exit cleanly.
        sys.exit(0)

# create hostgroups
for g in grouplist:
        try:
                item=zapi.hostgroup.create(name=g)
        except ZabbixAPIException as e:
                print(e)
		if e[1] == -32602:
                        sys.exit(0)
                else:
                        sys.exit(1)

# import the templates
try:
   templateFiles = os.listdir("/tmp/zabbix_templates")
except OSError as e:
   print e
   sys.exit(1)

for i in templateFiles:
   try:
       f = open("/tmp/zabbix_templates/"+i,'r')
   except IOError as e:
       print e
       sys.exit(1)

   templatexml = f.read()
   f.close()

   try:
        zapi.confimport(format='xml',source=templatexml,rules={'applications':{'createMissing':'true'}, 'discoveryRules':{'createMissing':'true'}, 'graphs':{'createMissing':'true'},'groups':{'createMissing':'true'}, 'hosts':{'createMissing':'true'}, 'images':{'createMissing':'true'}, 'items':{'createMissing':'true'},'maps':{'createMissing':'true'}, 'screens':{'createMissing':'true'}, 'templates':{'createMissing':'true'}, 'templateLinkage':{'createMissing':'true'}, 'templateScreens':{'createMissing':'true'}, 'triggers':{'createMissing':'true'} })
   except ZabbixAPIException as e:
        print(e)
        sys.exit(1)

# Get host group IDs
hostgroups = zapi.hostgroup.get(output='extend')

# build hostgroups dictionary
for t in hostgroups:
    gd[t['name']] = t['groupid']

# get template IDs

templates = zapi.template.get(output='extend')

# build templates dictionary
for t in templates:
	td[t['name']] = t['templateid']


# template lists
tall = ['Template OS Linux','Template App SSH Service','Template App SMTP Service','Template Linux Disk IO','Template App Beaver','Template ICMP Ping']

tg = defaultdict(list)
for i in grouplist:
	for j in tall:
		tg[i].append(j)

for i in ('Template App Logstash','Template App ElasticSearch', 'Template Redis 2', 'Template App HTTP Service','Template_Nginx'):
	tg['LOGGING'].append(i)

tg['RIAK'].append('Template App Riak')

tg['HAPROXY'].append('Template App HAProxy')


# create dict of templates to apply
ta = {}
for i in grouplist:
	ta[i] = [];
	for j in tg[i]:
		d = {'templateid': td[j].encode('ascii','ignore')}
		ta[i].append(d)

# create dict of metadata
metadata = {}
metadata['LOGGING'] = 'logging:t42OhEVyWj0PmK9qD9ibLWwEWy9xZ0Dj'
metadata['RIAK'] = 'riak:12t4fKciOpk9XLTwBfN76ZY0WibLMW1b'
metadata['HAPROXY'] = 'haproxy:3ZTN47LkxpWzP4p3WkhmwqQtLYibwWFm'

# create actions
for i in grouplist:
	filter = { 'evaltype': 0, 'conditions': [ { 'conditiontype': 24, 'operator': 2, 'value': metadata[i]}]}

	add_hostgroups = {'operationtype': 4, 'opgroup': [ {'groupid': gd['Linux servers'].encode('ascii','ignore')},{'groupid': gd[i].encode('ascii','ignore')}]}
	link_templates = {'operationtype': 6 , 'optemplate': ta[i]}
	
        if i == "LOGGING":
		jmx_command = {'command': "/var/lib/zabbix/bin/autoregister-jmx.py {HOST.HOST1}", 'type': 0, 'execute_on': 1 }
		add_jmx = {'operationtype': 1, 'opcommand': jmx_command, 'opcommand_hst': [ {'hostid': 0 } ]}
		operations = [add_hostgroups, add_jmx, link_templates]

	else:
		operations = [add_hostgroups, link_templates]

	aname = i + " Auto Registration" 
	try:
		zapi.action.create(name=aname, eventsource=2, filter=filter, operations=operations)
	except ZabbixAPIException as e:
                print(e)
                sys.exit(1)

# modfiy SMTP check - change to agent, have it monitor localhost
smtpitem  = zapi.item.get(templated='True',application='SMTP service')
newkey = 'net.tcp.port[127.0.0.1,25]'
id = smtpitem[0]['itemid'].encode('ascii','ignore')

try:
	zapi.item.update(itemid=id,key_=newkey,type=0)

except ZabbixAPIException as e:
        print(e)

# modfiy swap check
triggeritems = zapi.trigger.get(templated='True')
for t in triggeritems:
        if t['description'] == "Lack of free swap space on {HOST.NAME}":
                id = t['triggerid']

                try:
                        zapi.trigger.update(triggerid=id,status=1)

                except ZabbixAPIException as e:
                        print(e)

# Add templates to zabbix server
ztemplates = ('Template OS Linux','PostgreSQL Check', 'Template Linux Disk IO','Template App SMTP Service','Template App SSH Service','Template App HTTP Service')

zhost = zapi.host.get(host='Zabbix server')

zta = []
# build a dictionary of templates to apply
for i in ztemplates:
	d = {'templateid': td[i]}
	zta.append(d)

try:
	zapi.host.update(hostid=zhost[0]['hostid'], templates=zta, status=0)	
except ZabbixAPIException as e:
        print(e)
        sys.exit(1)

# Disable the 'Guests' group - users_status=1
filter= {'name': 'Guests'}
try:
        guestgroup = zapi.usergroup.get(filter=filter)
        zapi.usergroup.update(usrgrpid=guestgroup[0]['usrgrpid'],users_status=1)
except ZabbixAPIException as e:
        print(e)
        sys.exit(1)

