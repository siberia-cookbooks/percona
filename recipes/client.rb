#
# Cookbook Name:: percona
# Recipe:: default
#
# Copyright 2013, Jacques Marneweck
#
# All rights reserved - Do Not Redistribute
#

package "mysql-client" do
  action :remove
end

package "percona-client" do
  version node['percona']['version']
  action :install
end
