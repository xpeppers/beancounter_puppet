class redis::params {

  $redis_port = '6379'
  $redis_bind_address = false
  $version = '2.8.8'
  $redis_src_dir = '/tmp/other-repos/redis'
  $redis_bin_dir = '/tmp/other-repos/redis'
  $redis_max_memory = '4gb'
  $redis_max_clients = false
  $redis_timeout = 300         # 0 = disabled
  $redis_loglevel = 'notice'
  $redis_databases = 16
  $redis_slowlog_log_slower_than = 10000 # microseconds
  $redis_slowlog_max_len = 1024
  $redis_password = false

}