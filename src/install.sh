#!/bin/bash -e

# caddy
cat > /etc/caddy/caddy.conf << EOF
:80 {
  gzip
  root /data/www
  fastcgi / /data/run/php-fpm.sock php
  rewrite {
    if {path} not_match ^\/admin
    to {path} {path}/ /index.php?{query}
  }
}
EOF
rm -f /etc/init.d/caddy

# php7
sed -i "s@^memory_limit.*@memory_limit = 5M@" /etc/php7/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /etc/php7/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=1@' /etc/php7/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' /etc/php7/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' /etc/php7/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' /etc/php7/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /etc/php7/php.ini
sed -i 's@^post_max_size.*@post_max_size = 100M@' /etc/php7/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /etc/php7/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 600@' /etc/php7/php.ini
sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' /etc/php7/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' /etc/php7/php.ini
mv /etc/php7/php-fpm.conf /etc/php7/php-fpm.conf.bak
cat > /etc/php7/php-fpm.conf << EOF
[global]
pid = /data/run/php-fpm.pid
error_log = /data/log/php-fpm.log
log_level = warning
emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes
[caddy]
listen = /data/run/php-fpm.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = caddy
listen.group = caddy
listen.mode = 0666
user = caddy
group = caddy
pm = dynamic
pm.max_children = 3
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 8192
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0
pm.status_path = /php-fpm_status
slowlog = /data/log/slow.log
rlimit_files = 1200
rlimit_core = 0
catch_workers_output = yes
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF
rm -f /etc/init.d/php-fpm7

# supervisor
mkdir /etc/supervisord
cat > /etc/supervisord/supervisord.conf << EOF
[supervisord]
nodaemon=true
pidfile=/var/run/supervisord.pid

[program:php]
user=root
command=/usr/sbin/php-fpm7 --nodaemonize --fpm-config /etc/php7/php-fpm.conf
startsecs=10
startretries=100
autorstart=true
autorestart=true

[program:caddy]
user=root
command=/usr/sbin/caddy -conf /etc/caddy/caddy.conf -log /data/log/caddy.log -agree
startsecs=10
startretries=100
autorstart=true
autorestart=true
EOF

# typecho
mkdir -p /data/run
mkdir -p /data/log
mkdir -p /data/www
cd /data/www/
wget http://typecho.org/downloads/1.1-17.10.30-release.tar.gz
tar zxf 1.1-17.10.30-release.tar.gz 
rm -f 1.1-17.10.30-release.tar.gz
mv build/* ./
rm -rf build/
chown -R caddy:caddy /data/www