include:
 - common.riak
 - common.consul
 - common.riak.consul

# Configuration specific to a riak cluster

# Cluster join script
/tmp/cluster-join.sh:
  file.managed:
  - source: salt://profiles/riak/files/tmp/cluster-join.sh
  - user: root
  - group: root
  - mode: 700
  cmd.run:
  - require: 
    - service: riak
    - service: consul

