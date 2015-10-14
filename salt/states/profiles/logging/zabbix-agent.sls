include:
  - common.zabbix-agent

pyes:
  pip.installed:
   - name: pyes

zabbix-agent-conf-logging:
  file:
    - managed
    - name: /etc/zabbix/zabbix_agentd.conf
    - user: root
    - group: zabbix
    - source: salt://profiles/logging/files/etc/zabbix/zabbix_agentd.conf.jinja
    - template: jinja
    - context:
       host: {{ salt['pillar.get']('stack:master_address') }}
    - mode: 640
    - require:
      - pkg: zabbix-agent
    - watch_in:
      - service: zabbix-agent

zabbix-agentd-nginx-params-logging:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/nginx-params.conf
    - source: salt://profiles/logging/files/etc/zabbix/zabbix_agentd.d/nginx-params.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent

/etc/zabbix/zabbix_agentd.d/userparameter_es.conf:
  file.managed:
    - source: salt://profiles/logging/files/etc/zabbix/zabbix_agentd.d/userparameter_es.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-agent-redis-conf-logging:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/zbx_redis.conf
    - source: salt://profiles/logging/files/etc/zabbix/zabbix_agentd.d/zbx_redis.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent


nginx-stub-status-logging:
  file.managed:
    - name: /etc/nginx/sites-available/stub_status.conf
    - source: salt://profiles/logging/files/etc/nginx/sites-available/stub_status.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: zabbix-agent
      - pkg: nginx

nginx-sites-enabled-stub-status-logging:
  file.symlink:
    - name: /etc/nginx/sites-enabled/stub_status.conf
    - target: /etc/nginx/sites-available/stub_status.conf

zabbix-nginx-check-logging:
  file.managed:
    - name: /var/lib/zabbix/bin/nginx-check.sh
    - source: salt://profiles/logging/files/var/lib/zabbix/bin/nginx-check.sh
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent

/var/lib/zabbix/bin/elasticsearch.py:
  file.managed:
    - source: salt://profiles/logging/files/var/lib/zabbix/bin/elasticsearch.py
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-redis-stats-logging:
  file.managed:
    - name: /var/lib/zabbix/bin/zbx_redis_stats.py
    - source: salt://profiles/logging/files/var/lib/zabbix/bin/zbx_redis_stats.py
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent

