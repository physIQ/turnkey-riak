# create and mount data disks
include:
  - common.riak

/tmp/mkdisks.sh:
  file.managed:
  - source: salt://profiles/riak/files/tmp/mkdisks.sh
  - user: root
  - group: root
  - mode: 700
  cmd.run:
  - require:
    - file: /opt/riak/fast
    - file: /opt/riak/slow
    - file: /tmp/mkdisks.sh
  - require_in:
    - service: riak

