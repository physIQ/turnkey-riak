#!/usr/bin/env python

from pyzabbix import ZabbixAPI, ZabbixAPIException
import sys
from collections import defaultdict

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = 'https://127.0.0.1/zabbix'

zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify = False

# Login to the Zabbix API
zapi.login('Admin', 'zabbix')

# Get the host id
hostOut = zapi.host.get(filter={"host": sys.argv[1]})
hostID = hostOut[0]['hostid']

# Get the IP of the zabbix agent on the host
hostI = zapi.hostinterface.get(hostids=hostID)
newIP = hostI[0]['ip']

# Add the JMX interface
try:
    zapi.hostinterface.create(hostid=hostID,type=4,ip=newIP,port="12345",dns="",main=1,useip=1)
except ZabbixAPIException as e:
    print(e)
    sys.exit()

# Add the "Template JMX Generic" to the host

tOut = zapi.template.get()

for i in tOut:
	if i['host'] == "Template JMX Generic":
		templateID = i['templateid']

hostAdd = []
tAdd = []

hostAdd.append(hostID)
tAdd.append(templateID)

try:
	zapi.host.massadd(hosts=hostAdd,templates=tAdd)
except ZabbixAPIException as e:
        print(e)
        sys.exit()


