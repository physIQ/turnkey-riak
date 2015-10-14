nginx:
  pkg.installed

/srv/www:
  file.directory:
    - user: nginx
    - group: nginx

# ADD ROBOTS FILE TO STOP INDEXING
/srv/www/robots.txt:
  file.managed:
    - source: salt://common/nginx/files/srv/www/robots.txt
    - mode: 755
    - user: nginx
    - group: nginx
    - force: True
  require:
    - file: /srv/www


# ADD 404 File
/srv/www/404.html:
  file.managed:
    - source: salt://common/nginx/files/srv/www/404.html
    - mode: 755
    - user: nginx
    - group: nginx
    - force: True
  require:
    - file: /srv/www

# ADD 500 File
/srv/www/500.html:
  file.managed:
    - source: salt://common/nginx/files/srv/www/500.html
    - mode: 755
    - user: nginx
    - group: nginx
    - force: True
  require:
    - file: /srv/www


/etc/nginx/sites-available/:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/nginx/sites-enabled/:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/nginx/locations/:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/nginx:
  file.directory:
    - user: root
    - group: root

/etc/nginx/nginx.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/nginx/files/etc/nginx/nginx.conf
  require:
    - file: /etc/nginx

/etc/beaver/conf.d/nginx.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://common/nginx/files/etc/beaver/conf.d/nginx.conf
    - makedirs: True

# TURN ON LOGROTATE
/etc/logrotate.d/nginx:
  file.managed:
    - source: salt://common/nginx/files/etc/logrotate.d/nginx

# CREATE LISTENER FOR HTTP AND HTTPS
/etc/nginx/sites-available/http.conf:
  file.managed:
    - source: salt://common/nginx/files/etc/nginx/sites-available/http.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nginx/sites-available/
    - watch_in:
      - service: nginx

# CREATE LOCATION FOR PHP FILES
/etc/nginx/locations/php.conf:
  file.managed:
    - source: salt://common/nginx/files/etc/nginx/locations/php.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nginx/sites-available/
      - file: /etc/nginx/sites-available/http.conf
    - watch_in:
      - service: nginx

# ENABLE LISTENER FOR HTTP
/etc/nginx/sites-enabled/http.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/http.conf
    - require:
      - file: /etc/nginx/sites-enabled/
      - file: /etc/nginx/locations/php.conf
    - watch_in:
      - service: nginx

nginx-service:
  service:
    - name: nginx
    - running
    - enable: True
    - restart: True
    - require:
      - pkg: nginx

