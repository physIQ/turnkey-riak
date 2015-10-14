include:
  - common.consul

/etc/consul.d/postgresql.json:
  file.managed:
    - source: salt://common/postgres/files/etc/consul.d/postgresql.json
    - require_in:
        - service: consul

