define redis::instance (
  $redis_port = $redis::params::redis_port,
  $redis_bind_address = $redis::params::redis_bind_address,
  $redis_max_memory = $redis::params::redis_max_memory,
  $redis_max_clients = $redis::params::redis_max_clients,
  $redis_timeout = $redis::params::redis_timeout,
  $redis_loglevel = $redis::params::redis_loglevel,
  $redis_databases = $redis::params::redis_databases,
  $redis_slowlog_log_slower_than = $redis::params::redis_slowlog_log_slower_than,
  $redis_slowlog_max_len = $redis::params::redis_slowlog_max_len,
  $redis_password = $redis::params::redis_password
  ) {

  # Using Exec as a dependency here to avoid dependency cyclying when doing
  # Class['redis'] -> Redis::Instance[$name]
  Exec['install-redis'] -> Redis::Instance[$name]
  include redis
  
  file { "redis-lib-port-${redis_port}":
    ensure => directory,
    path   => "/var/lib/redis/${redis_port}",
  }

  file { "redis-init-${redis_port}":
    ensure  => present,
    path    => "/etc/init.d/redis_${redis_port}",
    mode    => '0755',
    content => template('redis/etc/init.d/redis.erb'),
    notify  => Service["redis-${redis_port}"],
  }
  file { "redis_port_${redis_port}.conf":
    ensure  => present,
    path    => "/etc/redis/${redis_port}.conf",
    mode    => '0644',
    content => template('redis/etc/redis/redis.conf.erb'),
  }

  service { "redis-${redis_port}":
    ensure    => running,
    name      => "redis_${redis_port}",
    enable    => true,
    require   => [ File["redis_port_${redis_port}.conf"], File["redis-init-${redis_port}"], File["redis-lib-port-${redis_port}"] ],
    subscribe => File["redis_port_${redis_port}.conf"],
  }
}