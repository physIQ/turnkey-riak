include:
  - common.consul
  - common.consul.agent
  - common.zabbix-agent.consul
  - common.elk-stack.consul

/etc/consul.d/logging.json:
  file.managed:
    - source: salt://profiles/logging/files/etc/consul.d/logging.json
    - require_in:
      - service: consul

