vm.swappiness:
  sysctl.present:
    - value: 0

/etc/security/limits.d/30-riak.conf:
  file.managed:
  - source: salt://profiles/riak/files/etc/security/limits.d/30-riak.conf
  - user: root
  - group: root

/sbin/grubby --update-kernel=ALL --args="elevator=noop":
  cmd.run

echo noop > /sys/block/sda/queue/scheduler:
  cmd.run

echo noop > /sys/block/sdb/queue/scheduler:
  cmd.run

echo noop > /sys/block/sdc/queue/scheduler:
  cmd.run

