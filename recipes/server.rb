#
# Cookbook Name:: percona
# Recipe:: default
#
# Copyright 2013, Jacques Marneweck
#
# All rights reserved - Do Not Redistribute
#

package "percona-server" do
  action :install
end

include_recipe "percona::client"
include_recipe "percona::toolkit"

service "percona-server" do
  action [ :enable ]
end

template "/root/.my.cnf" do
  source "root__.my.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
end

template "/opt/local/etc/my.cnf" do
  source "opt__local__etc__my.cnf.erb"
  owner "root"
  group "mysql"
  mode "0640"
end

directory "/var/log/mysql" do
  owner "mysql"
  group "mysql"
  mode "0755"
end

#
# Needed for flushing privileges post removing of users
#
execute "flush-mysql-privileges" do
  command "/opt/local/bin/mysqladmin -u root flush-privileges"
  only_if "/opt/local/bin/mysql --no-defaults -u root -e 'show databases;'"
  action :nothing
end

#
# Set mysql's password
#
execute "assign-root-password-socket" do
  command "/opt/local/bin/mysqladmin --no-defaults -u root password \"#{node['percona']['server_root_password']}\""
  action :run
  only_if "/opt/local/bin/mysql --no-defaults -u root -e 'show databases;' "
end

execute "assign-root-password-localhost" do
  command "/opt/local/bin/mysql -u root mysql -e \"SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{node['percona']['server_root_password']}');\""
  Chef::Log.info("/opt/local/bin/mysql -u root mysql -e \"SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{node['percona']['server_root_password']}');\"")
  only_if "/opt/local/bin/mysql --no-defaults -u root -e 'show databases;' "
  action :run
end
