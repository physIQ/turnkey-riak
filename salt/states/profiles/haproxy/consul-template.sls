include:
  - common.consul-template

/etc/consul-template.d/configs/haproxy.conf:
  file.managed:
  - source: salt://profiles/haproxy/files//etc/consul-template.d/configs/haproxy.conf
  - user: root
  - group: root
  - mode: 755
  - makedirs: True

/etc/consul-template.d/templates/haproxy.cfg.templ:
  file.managed:
  - source: salt://profiles/haproxy/files//etc/consul-template.d/templates/haproxy.cfg.templ
  - user: root
  - group: root
  - mode: 755
  - makedirs: True
  - require_in:
    - service: haproxy


