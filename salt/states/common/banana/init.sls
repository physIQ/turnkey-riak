include:
  - common.nginx

git:
  pkg.installed

banana: 
  cmd.run:
   - name: git clone https://github.com/LucidWorks/banana.git
   - cwd: /opt
   - unless: ls /opt/banana

/etc/consul-template.d/configs/banana.conf:
   file.managed:
     - source: salt://common/banana/files/etc/consul-template.d/configs/banana.conf
     - mode: 644
     - user: root
     - group: root

/etc/consul-template.d/templates/banana.conf.templ:
   file.managed:
     - source: salt://common/banana/files/etc/consul-template.d/templates/banana.conf.templ
     - mode: 644
     - user: root
     - group: root

