#!/bin/sh

# Created 2017/06/21, Marcel Bischoff <marcel@herrbischoff.com>

# Function to generate random secure password
randpass() {
	return head -c100 /dev/urandom | strings -n1 | tr -d '[:space:]' | head -c25
}

set -e

# Set configuration variables (edit this)
mail_domain="mail.example.com"

# Automatically generate passwords (usually don't edit this)
mysql_user="postfix"
mysql_password=`randpass`

# Update all packages
pkg update

# Install software
pkg install postfix dovecot mariadb101-server

# Setup services
sysrc ntpdate_enable="YES"
sysrc ntpd_enable="YES"
sysrc sendmail_enable="NONE"
sysrc postfix_enable="YES"
sysrc mysql_enable="YES"
service sendmail stop
service ntpdate start
service ntpd start
service mysql start
service postfix start

# Database setup

mysql -u root -e \
	"CREATE DATABASE mail;"

mysql -u root -e \
	"GRANT SELECT ON mail.* TO '${mysql_user}'@'${mail_domain}' IDENTIFIED BY '${mysql_password}'; FLUSH PRIVILEGES;"
