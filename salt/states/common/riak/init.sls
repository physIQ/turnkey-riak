include:
  - common.java
  - common.riak.consul

riak:
  pkg.installed:
    - sources:
      - riak: {{ salt['pillar.get']('software:riak:url') }}
  service:
    - running
    - enable: True
    - provider: service
    - require:
      - pkg: riak
