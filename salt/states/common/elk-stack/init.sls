include:
  - common.java
  - common.redis
  - common.nginx

#INSTALL AND CONFIGURE ELASTICSEARCH SERVICE
elasticsearch:
  pkg.installed:
    - sources:
      - elasticsearch: {{ salt['pillar.get']('software:elasticsearch:url') }}
  service:
    - running
    - enable: True
    - require:
      - pkg: elasticsearch
    - watch:
        - file: /etc/elasticsearch/*
  require:
    - sls: common.java

# CREATE ELASTICSEARCH CONFIGURATION FILES
/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - source: salt://common/elk-stack/files/etc/elasticsearch/elasticsearch.yml
  require:
    - pkg: elasticsearch

/etc/elasticsearch/logging.yml:
  file.managed:
    - source: salt://common/elk-stack/files/etc/elasticsearch/logging.yml
  require:
    - pkg: elasticsearch

#INSTALL AND CONFIGURE LOGSTASH SERVICE
install-logstash:
  pkg.installed:
    - sources:
      - logstash: {{ salt['pillar.get']('software:logstash:url') }}
  require:
    - sls: common.redis
    - sls: common.java
    - pkg: elasticsearch

# CREATE LOGSTASH CONFIGURATION FILES
/etc/logstash/conf.d/logstash.conf:
  file:
    - managed
    - source: salt://common/elk-stack/files/etc/logstash/conf.d/logstash.conf
  require:
    - file: /etc/logstash/conf.d
    - pkg: elasticsearch
    - pkg: logstash

/etc/logstash/patterns:
  file.recurse:
    - source: salt://common/elk-stack/files/etc/logstash/patterns
    - include_empty: True

/etc/sysconfig/logstash:
  file.append:
    - text:
      - JAVA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
      - LS_OPTS="--pluginpath /opt/logstash/lib"

#INSTALL CUSTOM LOGSTASH FILTERS
/opt/logstash/lib/logstash/filters/level.rb:
  file:
    - managed
    - source: salt://common/elk-stack/files/opt/logstash/filters/level.rb
    - makedirs: True
  require:
    - pkg: logstash


# CREATE AND START LOGSTASH SERVICE
configure-logstash-service:
  service.running:
    - name: logstash
    - enable: True
  require:
    - pkg: logstash
    - file: /etc/logstash/conf.d/logstash.conf

# INSTALL AND CONFIGURE KIBANA 4.0
extract-install-kibana:
  archive.extracted:
    - name: /opt/kibana/
    - source: {{ salt['pillar.get']('software:kibana:url') }}
    - source_hash: {{ salt['pillar.get']('software:kibana:sha') }}
    - archive_format: tar
    - tar_options: "xz --strip=1"
  file.managed:
    - name: /opt/kibana/config/kibana.yml
    - source: salt://common/elk-stack/files/opt/kibana/config/kibana.yml
    - mode: 644
    - user: root
    - group: root
    - require:
      - archive: /opt/kibana/
  require:
    - pkg: elasticsearch
    - pkg: logstash


# SETUP KIBANA SERVICE - TODO WHY CAN'T WE USE SALT SERVICE STATE
install-kibana-service:
  file.managed:
    - name: /etc/systemd/system/kibana4.service
    - source: salt://common/elk-stack/files/etc/systemd/system/kibana4.service
  cmd.run:
    - name: "systemctl start kibana4"
  require:
    - pkg: elasticsearch
    - pkg: logstash
enable-kibana-service:
  cmd.run:
    - name: "systemctl enable kibana4"
  require:
    - pkg: elasticsearch
    - pkg: logstash
    - file: /etc/systemd/system/kibana4.service

#  service.running:
#    - name: kibana4.service
#    - enable: True
#    - provider: service
#    - watch:
#      - file: /opt/kibana/config/*
#  require:
#    - pkg: elasticsearch
#    - pkg: logstash



/etc/nginx/locations/kibana.conf:
  file.managed:
    - source: salt://common/elk-stack/files/etc/nginx/locations/kibana.conf
    - mode: 644
    - user: root
    - group: root
    - watch_in:
      - service: nginx-service
    - require_in:
      - service: nginx-service

# ADD LOGS TO BEAVER
/etc/beaver/conf.d/elasticsearch.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/elk-stack/files/etc/beaver/conf.d/elasticsearch.conf

/etc/beaver/conf.d/logstash.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/elk-stack/files/etc/beaver/conf.d/logstash.conf

# TODO - add logs from kibana to beaver

# TURN ON LOGROTATE FOR LOGS
/etc/logrotate.d/logstash:
  file.managed:
    - source: salt://common/elk-stack/files/etc/logrotate.d/logstash

