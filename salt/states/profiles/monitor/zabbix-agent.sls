include:
  - common.zabbix-agent

zabbix-agent-conf-monitor:
  file:
    - managed
    - name: /etc/zabbix/zabbix_agentd.conf
    - user: root
    - group: zabbix
    - source: salt://profiles/monitor/files/etc/zabbix/zabbix_agentd.conf.jinja
    - template: jinja
    - context: {{ salt['pillar.get']('monitor') }}
    - mode: 640
    - require:
      - pkg: zabbix-agent
    - watch_in: 
      - service: zabbix-agent
