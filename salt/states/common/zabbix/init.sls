zabbix-repo:
  cmd.run:
     - name: yum localinstall -y {{ salt['pillar.get']('software:zabbix:url') }}
