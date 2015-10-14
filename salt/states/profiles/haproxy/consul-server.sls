include:
  - common.consul
  - common.consul.server
  - common.zabbix-agent.consul

/etc/consul.d/haproxy.json:
  file.managed:
    - source: salt://profiles/haproxy/files/etc/consul.d/haproxy.json
    - require_in:
      - service: consul

