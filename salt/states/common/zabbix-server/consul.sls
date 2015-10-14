include:
  - common.consul

/etc/consul.d/zabbix-server.json:
  file.managed:
    - source: salt://common/zabbix-server/files/etc/consul.d/zabbix-server.json
    - require_in:
      - service: consul

