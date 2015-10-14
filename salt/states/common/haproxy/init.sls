haproxy-pkg:
  pkg.installed:
  - name: haproxy

fs.file-max:
  sysctl.present:
  - value: 2560000

haproxy:
  service:
   - running
   - enable: True
