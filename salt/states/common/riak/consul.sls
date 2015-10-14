include:
  - common.consul

/etc/consul.d/riak.json:
  file.managed:
  - source: salt://common/riak/files/etc/consul.d/riak.json
  - user: root
  - group: root
  - mode: 655
  - require_in:
    - service: consul

/etc/consul.d/solr.json:
  file.managed:
  - source: salt://common/riak/files/etc/consul.d/solr.json
  - user: root
  - group: root
  - mode: 655
  - require_in:
    - service: consul

