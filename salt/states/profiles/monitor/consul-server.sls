include:
  - common.consul
  - common.consul.server
  - common.zabbix-agent.consul
  - common.zabbix-server.consul

exclude:
  - file: /etc/consul.d/002-join.json

/etc/consul.d/monitor.json:
  file.managed:
    - source: salt://profiles/monitor/files/etc/consul.d/monitor.json
    - require_in:
      - service: consul

/etc/consul.d/bind-master.json:
  file.managed:
    - source: salt://profiles/monitor/files/etc/consul.d/bind-master.json
    - require_in:
      - service: consul

/etc/consul.d/001-bootstrap.json:
  file.managed:
    - source: salt://profiles/monitor/files/etc/consul.d/001-bootstrap.json
    - require_in: 
      - service: consul 
  
/etc/consul.d/smtp-relay.json:
  file.managed:
    - source: salt://profiles/monitor/files/etc/consul.d/smtp-relay.json
    - require_in:
      - service: consul

