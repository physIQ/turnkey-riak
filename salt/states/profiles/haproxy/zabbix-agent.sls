include:
  - common.zabbix-agent

socat:
  pkg.installed

zabbix-agent-conf-haproxy:
  file:
    - managed
    - name: /etc/zabbix/zabbix_agentd.conf
    - user: root
    - group: zabbix
    - source: salt://profiles/haproxy/files/etc/zabbix/zabbix_agentd.conf.jinja
    - template: jinja
    - context: 
       master_address: {{ salt['pillar.get']('stack:master_address') }}
    - mode: 640
    - require:
      - pkg: zabbix-agent
    - watch_in: 
      - service: zabbix-agent

zabbix-agent-haproxy-conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparamter_haproxy.conf
    - source: salt://profiles/haproxy/files/etc/zabbix/zabbix_agentd.d/userparameter_haproxy.conf
    - mode: 640
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent

zabbix-haproxy-discovery:
  file.managed:
    - name: /var/lib/zabbix/bin/haproxy_discovery.sh
    - source: salt://profiles/haproxy/files/var/lib/zabbix/bin/haproxy_discovery.sh
    - mode: 750
    - user: zabbix
    - group: zabbix
    - require:
      - pkg: zabbix-agent
