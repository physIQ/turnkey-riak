redis-install:
  pkg.installed:
   - name: redis

redis:
  service:
   - running
   - enable: True

/etc/redis.conf:
  file.comment: 
    - regex: ^bind 127.0.0.1
    - watch_in:
      - service: redis
  require:
    - pkg: redis

# CONFIGURE REDIS LOG SHIPPING AND ROTATION
/etc/beaver/conf.d/redis.conf:
  file.managed:
    - user: root
    - group: root
    - source: salt://common/redis/files/etc/beaver/conf.d/redis.conf

# CONFIGURE LINUX OVERCOMMIT_MEMORY = 1 PARAMETER
vm.overcommit_memory:
  sysctl.present:
   - value: 1
