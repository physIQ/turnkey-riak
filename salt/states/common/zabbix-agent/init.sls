include:
  - common.consul
  - common.zabbix

zabbix-agent:
  pkg.installed:
    - name: zabbix-agent
  service:
    - running
    - enable: True
    - order: last

/var/lib/zabbix/bin:
   file.directory:
    - user: zabbix
    - group: zabbix
    - mode: 750
    - makedirs: True
    - require:
      - pkg: zabbix-agent

/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf:
  file:
    - absent

/etc/zabbix/zabbix_agentd.d/userparameter_linux_disks.conf:
  file:
    - managed
    - user: zabbix
    - group: zabbix
    - source: salt://common/zabbix-agent/files//etc/zabbix/zabbix_agentd.d/userparameter_linux_disks.conf
    - mode: 640
    - require:
      - pkg: zabbix-agent

/var/lib/zabbix/bin/queryDisks.pl:
   file:
    - managed
    - user: zabbix
    - group: zabbix
    - source: salt://common/zabbix-agent/files/var/lib/zabbix/bin/queryDisks.pl
    - mode: 750
    - require:
      - pkg: zabbix-agent

/etc/zabbix/zabbix_agentd.d/systemd_status.conf:
  file:
    - managed
    - user: zabbix
    - group: zabbix
    - source: salt://common/zabbix-agent/files/etc/zabbix/zabbix_agentd.d/systemd_status.conf
    - mode: 640
    - require:
      - pkg: zabbix-agent

/etc/logrotate.d/zabbix-agent:
   file.managed:
    - source: salt://common/zabbix-agent/files/etc/logrotate.d/zabbix-agent


