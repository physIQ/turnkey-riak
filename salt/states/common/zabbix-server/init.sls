include:
  - common.nginx
  - common.php
  - common.postgres
  - common.zabbix

zabbix-server-install:
  pkg.installed:
   - pkgs:
     - zabbix
     - zabbix-server
     - zabbix-get
     - zabbix-server
     - zabbix-server-pgsql
     - zabbix-web
     - zabbix-web-pgsql
     - zabbix-java-gateway

/etc/zabbix/zabbix_java_gateway.conf:
  file:
  - managed
  - source: salt://common/zabbix-server/files/etc/zabbix/zabbix_java_gateway.conf
  - user: root
  - group: zabbix
  - mode: 640
  
zabbix-java-gateway:
  service:
  - running
  - enable: True
  watch:
  - file: /etc/zabbix-server/zabbix_java_gateway.conf 

pyzabbix:
  pip.installed:
   - name: pyzabbix

/etc/zabbix/zabbix_server.conf:
  file:
    - managed
    - user: root
    - group: zabbix
    - source: salt://common/zabbix-server/files/etc/zabbix/zabbix_server.conf
    - mode: 640

/etc/zabbix/web/zabbix.conf.php:
  file:
    - managed
    - user: zabbix
    - group: apache
    - source: salt://common/zabbix-server/files/etc/zabbix/web/zabbix.conf.php
    - mode: 440

/tmp/zabbix_templates:
   file.recurse:
    - user: root
    - group: root
    - source: salt://common/zabbix-server/files/tmp/zabbix_templates
    - file_mode: 600
    - dir_mode: 600

#CONFIGURE POSTGRES
zabbix:
  postgres_user.present:
    - user: postgres
    - name: zabbix
  postgres_database.present:
    - user: postgres
    - owner: zabbix
    - encoding: UTF8
  require:
    - service: postgresql

psql zabbix < /usr/share/doc/zabbix-server-pgsql-`rpm -q --qf "%{VERSION}\n" zabbix`/create/schema.sql && psql zabbix < /usr/share/doc/zabbix-server-pgsql-`rpm -q --qf "%{VERSION}\n" zabbix`/create/images.sql && psql zabbix < /usr/share/doc/zabbix-server-pgsql-`rpm -q --qf "%{VERSION}\n" zabbix`/create/data.sql:
  cmd.run:
    - user: zabbix

/tmp/disk-regexp.sql:
  file.managed:
    - source: salt://common/zabbix-server/files/tmp/disk-regexp.sql
    - mode: 644
    - user: postgres
    - group: postgres

/tmp/rabbitmq-regexp.sql:
  file.managed:
    - source: salt://common/zabbix-server/files/tmp/rabbitmq-regexp.sql
    - mode: 644
    - user: postgres
    - group: postgres

psql zabbix < /tmp/disk-regexp.sql:
  cmd.run:
    - user: zabbix

psql zabbix < /tmp/rabbitmq-regexp.sql:
  cmd.run:
    - user: zabbix

zabbix-server:
  service:
   - running
   - enable: True
   - watch:
     - file: /etc/zabbix/zabbix_server.conf

# NGINX ZABBIX CONFIGURATION

zabbix-nginx-symlink:
  file.symlink:
    - name: /srv/www/zabbix
    - target: /usr/share/zabbix

/etc/zabbix/web:
  file.directory:
    - file_mode: 755
    - dir_mode: 755
    - recurse:
      - mode

/usr/share/zabbix:
  file.directory:
    - file_mode: 755
    - dir_mode: 755
    - recurse:
      - mode

/etc/nginx/locations/zabbix.conf:
  file.managed:
    - source: salt://common/zabbix-server/files/etc/nginx/locations/zabbix.conf
    - mode: 644
    - user: root
    - group: root
    - watch_in:
      - service: nginx
      - service: php-fpm
    - require_in:
      - service: nginx
      - service: php-fpm
  cmd.run:
    - name: /bin/systemctl restart php-fpm

/var/lib/zabbix/bin/autoregister-jmx.py:
   file:
    - managed
    - user: zabbix
    - group: zabbix
    - source: salt://common/zabbix-server/files/var/lib/zabbix/bin/autoregister-jmx.py
    - mode: 755
    - makedirs: True

/tmp/configure_zabbix.py:
   file:
    - managed
    - user: root
    - group: root
    - source: salt://common/zabbix-server/files/tmp/configure_zabbix.py
    - mode: 700
   cmd.run:
    - user: root
   require:
    - file: /etc/nginx/locations/zabbix.conf

/etc/logrotate.d/zabbix-server:
   file.managed:
    - source: salt://common/zabbix-server/files/etc/logrotate.d/zabbix-server
