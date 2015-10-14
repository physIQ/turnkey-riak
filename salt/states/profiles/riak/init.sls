include:
  - common.riak
  - common.consul
  - common.consul.agent
  - profiles.riak.disks
  - profiles.riak.tuning
  - profiles.riak.cluster
  - profiles.riak.zabbix-agent
  - profiles.riak.consul-agent

/opt/riak/fast:
  file.directory:
  - makedirs: True
  - user: riak
  - group: riak
  - dir_mode: 755
  - file_mode: 644
  - recurse:
    - user
    - group
    - mode
  - require_in:
    - service: riak
  require:
  - file: /opt/riak

/opt/riak/slow:
  file.directory:
  - makedirs: True
  - user: riak
  - group: riak
  - dir_mode: 755
  - file_mode: 644
  - recurse:
    - user
    - group
    - mode
  - require_in:
    - service: riak
  require:
  - file: /opt/riak

# Config file
/etc/riak/riak.conf:
  file.managed:
  - source: salt://profiles/riak/files/etc/riak/riak.conf
  - template: jinja
  - context:
    node_name: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
  - user: riak
  - group: riak
  - mode: 640
  - makedirs: True
  - require_in:
    - service: riak
  - watch_in:
    - service: riak

