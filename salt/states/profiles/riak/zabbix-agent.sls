include:
  - common.zabbix-agent

zabbix-agent-conf-riak:
  file:
    - managed
    - name: /etc/zabbix/zabbix_agentd.conf
    - user: root
    - group: zabbix
    - source: salt://profiles/riak/files/etc/zabbix/zabbix_agentd.conf.jinja
    - template: jinja
    - context:
       host: {{ salt['pillar.get']('stack:master_address') }}
    - mode: 640
    - require:
      - pkg: zabbix-agent
    - watch_in: 
      - service: zabbix-agent

zabbix-agent-riak-conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_riak.conf
    - source: salt://profiles/riak/files/etc/zabbix/zabbix_agentd.d/userparameter_riak.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-riak-crontab:
   file.append:
     - name: /etc/crontab
     - source: salt://profiles/riak/files/etc/crontab

