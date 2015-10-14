include:
  - common.consul

/etc/consul.d/elk-stack.json:
  file.managed:
    - source: salt://common/elk-stack/files/etc/consul.d/elk-stack.json
    - require_in:
      - service: consul
