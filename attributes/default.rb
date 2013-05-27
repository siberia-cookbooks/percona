#
# Cookbook Name:: percona
# Attributes:: default
#
# Copyright 2013, Jacques Marneweck
#
# All rights reserved - Do Not Redistribute
#

default['percona'] = {
  'percona_version' => '55',
  'ssl' => '1',
  'bind_address' => '127.0.0.1',
  'service_name' => 'pkgsrc/percona-server',
  'server_root_password' => 'egMacpadvedjifsAsjobGiopwagshErm',
  'key_buffer_size' => '170M',
  'myisam_sort_buffer_size' => '32M',
  'innodb_buffer_pool_size' => '170M',
  'table_cache' => '1024',
  'query_cache_size' => '64M',
  'thread_concurrency' => '16',
  'max_connections' => '200',
  'server_id' => 1,
  'expire_logs_days' => '7',
  'thread_cache_size' => '100',
  'back_log' => '500',
  'replication' => {
  }
}
