#
# Cookbook Name:: percona
# Recipe:: default
#
# Copyright 2013-2014, Jacques Marneweck
#
# All rights reserved - Do Not Redistribute
#

package "percona-server" do
  version node['percona']['version']
  action :install
end

include_recipe "percona::client"

cmd=Mixlib::ShellOut.new('cat /etc/pkgsrc_version | grep release | cut -d\' \' -f2')
cmd.run_command
cmd.error!
pkgsrc_version = cmd.stdout.strip

case pkgsrc_version
when "2013Q1", "2013Q2", "2013Q3"
  include_recipe "percona::toolkit"
end

directory "/var/mysql" do
  owner "mysql"
  group "mysql"
  mode "0750"
end

directory "/var/log/mysql" do
  owner "mysql"
  group "mysql"
  mode "0755"
end

template "/opt/local/etc/my.cnf" do
  source "opt__local__etc__my.cnf.erb"
  owner "root"
  group "mysql"
  mode "0640"
end

template "/root/.my.cnf" do
  source "root__.my.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
end

execute "mysql_install_db" do
  command "/opt/local/bin/mysql_install_db --user=mysql --datadir=/var/mysql --skip-name-resolve --force"
  not_if { ::File.exists?("/var/mysql/mysql/user.frm") }
end

service node['percona']['service_name'] do
  action [ :enable ]
end

ruby_block "wait for percona to come up" do
  block do
    Timeout::timeout(60) do
      until system("ls /tmp/mysql.sock")
        sleep 1
      end
    end
  end
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
  command "/opt/local/bin/mysqladmin password '#{node['percona']['server_root_password']}'"
  Chef::Log.info("/opt/local/bin/mysqladmin password '#{node['percona']['server_root_password']}'")
  only_if "/opt/local/bin/mysql --no-defaults -u root -e 'show databases;'"
  action :run
end

execute "assign-root-password-127.0.0.1" do
  command "/opt/local/bin/mysqladmin --no-defaults -h 127.0.0.1 password '#{node['percona']['server_root_password']}'"
  Chef::Log.info("/opt/local/bin/mysqladmin --no-defaults -h 127.0.0.1 password '#{node['percona']['server_root_password']}'")
  only_if "/opt/local/bin/mysql --no-defaults -h 127.0.0.1 -u root -e 'show databases;'"
  action :run
end

#
# Drop 'test' database
#
execute "drop-test-database" do
  command "echo y | /opt/local/bin/mysqladmin drop test"
  only_if "test -d /var/mysql/test"
end

#
# Import Timezone Data
#
execute "import-timezone-data" do
  command "/opt/local/bin/mysql_tzinfo_to_sql /usr/share/lib/zoneinfo | mysql -u root mysql"
  only_if "mysql -e \"show databases;\" | grep mysql"
  not_if "mysql -e \"select * from mysql.time_zone;\" | grep leap_seconds"
end
