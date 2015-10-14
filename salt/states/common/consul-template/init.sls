consul-template-binary:
  archive.extracted:
  - name: /tmp/consul-template
  - source: salt://common/consul-template/files/consul-template_0.10.0_linux_amd64.tar.gz
  - archive_format: tar
  cmd.run:
  - name: | 
       cp /tmp/consul-template/consul-template_0.10.0_linux_amd64/consul-template /usr/local/sbin
       chmod 755 /usr/local/sbin/consul-template
  - unless:
    - file: /usr/local/sbin/consul-template

/etc/consul-template.d/configs/01-base.conf:
  file:
  - managed
  - source: salt://common/consul-template/files/etc/consul-template.d/configs/01-base.conf
  - makedirs: True
  
/etc/systemd/system/consul-template.service:
  file:
  - managed
  - source: salt://common/consul-template/files/etc/systemd/system/consul-template.service

consul-template:
  service:
  - running
  - enable: True
  - order: last
