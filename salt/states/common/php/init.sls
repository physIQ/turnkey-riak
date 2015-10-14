php-fpm:
  pkg.installed:
    - pkgs:
      - php-fpm
      - php-mcrypt
      - php-pgsql

/etc/php.ini:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://common/php/files/etc/php.ini

/etc/php-fpm.d/www.conf:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://common/php/files/etc/php-fpm.d/www.conf

php-fpm-service:
  service:
    - name: php-fpm
    - running
    - enable: True
    - watch:
      - pkg: php-fpm
      - file: /etc/php.ini
      - file: /etc/php-fpm.d/www.conf
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/sites-enabled/*
      - file: /etc/nginx/locations/*
