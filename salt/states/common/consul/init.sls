unzip:
  pkg.installed

consul-binary:
  archive.extracted:
  - name: /tmp/consul
  - source: {{ salt['pillar.get']('software:consul:url') }}
  - source_hash: md5={{ salt['pillar.get']('software:consul:md5') }}
  - archive_format: zip
  - unless:
    - file: /usr/local/sbin/consul 
  cmd.run:
  - name: |
       cp /tmp/consul/consul /usr/local/sbin
       chmod 755 /usr/local/sbin/consul
  - unless:
    - file: /usr/local/sbin/consul 

/etc/systemd/system/consul.service:
  file.managed:
  - source: salt://common/consul/files/etc/systemd/system/consul.service

/etc/consul.d:
  file.directory:
  - makedirs: True
  - require_in:
    - service: consul

/opt/consul:
  file.directory:
  - user: daemon
  - group: daemon
  - mode: 700
  - makedirs: True
  - require_in:
    - service: consul

{% if grains['stack']['node_type'] != "master" %}
/etc/consul.d/002-join.json:
  file.managed:
  - source: salt://common/consul/files/etc/consul.d/002-join.json.jinja
  - template: jinja
  - master_address: {{ salt['pillar.get']('stack:master_address') }}
  - require_in:
    - service: consul
{% endif %}

consul:
  service:
  - name: consul
  - running
  - enable: True
  require:
  - file: /etc/systemd/system/consul.service
  - pkg: consul

