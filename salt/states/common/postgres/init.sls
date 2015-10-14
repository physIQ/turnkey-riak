# INSTALL POSTGRES
postgresql-server:
  pkg.installed

# INITIALIZE POSTGRES
initdb:
  cmd:
    - run
    - user: root
    - name: postgresql-setup initdb
    - unless:
      - ls /var/lib/pgsql/initdb.log
    - require: 
      - pkg: postgresql-server

/var/lib/pgsql/data/pg_hba.conf:
  file.replace:
    - pattern: (peer|ident)$
    - repl: trust
    - count: 3
    - watch_in:
      - service: postgresql
  require:
    - cmd: initdb

postgres-service:
  service.running:
    - name: postgresql
    - enable: True

# CONFIGURE POSTGRES LOG SHIPPING AND ROTATION
/etc/beaver/conf.d/postgres.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/postgres/files/etc/beaver/conf.d/postgres.conf

