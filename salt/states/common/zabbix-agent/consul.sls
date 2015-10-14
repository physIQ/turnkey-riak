include:
  - common.consul

/etc/consul.d/zabbix-agent.json:
  file.managed:
    - source: salt://common/zabbix-agent/files/etc/consul.d/zabbix-agent.json
    - require_in:
      - service: consul

