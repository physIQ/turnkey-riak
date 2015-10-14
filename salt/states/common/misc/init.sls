misc_packages:
  pkg.installed:
   - pkgs:
     - net-tools
     - mlocate
     - nmap-ncat
     - screen
     - strace
     - bind-utils

firewalld:
  service:
   - disable: True
   - dead

