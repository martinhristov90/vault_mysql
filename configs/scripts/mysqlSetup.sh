#!/usr/bin/env bash

# Mysql listens on all interfaces
sed -i '/bind-address=*/c\bind-address=0.0.0.0' /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl stop mysql
sleep 1

systemctl start mysql
sleep 1

# User and pass for MySQL
USER=root
PASSWORD=SET_YOUR_PASS

mysql -u${USER} -p${PASSWORD} -e "show databases;" | grep "test_db" || {
  mysql -u${USER} -p${PASSWORD} --silent -e "source /vagrant/configs/scripts/setup_mysql.sql" 2>&1
}

