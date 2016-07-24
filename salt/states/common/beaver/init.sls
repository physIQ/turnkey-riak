include:
  - common.consul-template

#CREATE BEAVER FOLDER STRUCTURE
/etc/beaver:
  file.directory

/etc/beaver/conf.d:
  file.directory:
    - require:
      - file: /etc/beaver

/var/log/beaver:
  file.directory

#INSTALL BEAVER
beaver:
  pip.installed:
    - name: beaver
  service:
    - running
    - enable: True
    - require:
      - pip: beaver
      - file: /etc/systemd/system/beaver.service
    - watch:
      - file: /etc/beaver/*




#CONFIGURE BEAVER
/etc/consul-template.d/configs/beaver.conf:
  file.managed:
    - source: salt://common/beaver/files/etc/consul-template/configs/beaver.conf
    - require:
      - file: /etc/beaver
      - file: /etc/beaver/conf.d
      - file: /var/log/beaver
    - makedirs: True

/etc/consul-template.d/templates/beaver.conf.templ:
  file.managed:
    - source: salt://common/beaver/files/etc/consul-template/templates/beaver.conf.templ
    - require:
      - file: /etc/beaver
      - file: /etc/beaver/conf.d
      - file: /var/log/beaver
    - makedirs: True

#CONFIGURE SYSTEMD STARTUP
#CONFIGURE SYSTEMD STARTUP
/etc/systemd/system/beaver.service:
  file.managed:
    - source: salt://common/beaver/files/etc/systemd/system/beaver.service




# ADD SALT LOGS TO BEAVER
/etc/beaver/conf.d/salt.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/beaver/files/etc/beaver/conf.d/salt.conf



# TURN ON LOGROTATE FOR SALT LOGS
/etc/logrotate.d/salt:
  file.managed:
    - source: salt://common/beaver/files/etc/logrotate.d/salt
