include:
  - common.gcc
  - common.zabbix-server
  - common.zabbix-agent
  - profiles.monitor.consul-server
  - common.banana

zabbix-agent-userparameter-pgsql-conf-monitor:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_pgsql.conf
    - source: salt://profiles/monitor/files/etc/zabbix/zabbix_agentd.d/userparameter_pgsql.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-find-dbname-monitor:
  file.managed:
    - name: /var/lib/zabbix/bin/find_dbname.sh
    - source: salt://profiles/monitor/files/var/lib/zabbix/bin/find_dbname.sh
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-find-dbname-table-monitor:
  file.managed:
    - name: /var/lib/zabbix/bin/find_dbname_table.sh
    - source: salt://profiles/monitor/files/var/lib/zabbix/bin/find_dbname_table.sh
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent

protobuf-c-devel:
  pkg.installed

gcloud:
  pip.installed:
  - name: gcloud
  require:
  - pkg: common.gcc
  - pkg: protobuf-c-devel

