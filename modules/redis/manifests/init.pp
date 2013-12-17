class redis (
  $version = $redis::params::version,
  $redis_src_dir = $redis::params::redis_src_dir,
  $redis_bin_dir = $redis::params::redis_bin_dir
) inherits redis::params {

  $redis_pkg_name = "redis-${version}.tar.gz"
  $redis_pkg = "/tmp/other-repos/${redis_pkg_name}"
  $redis_service = "redis_${redis_port}"

  # Install default instance
  redis::instance { 'redis-default': }

  File {
    owner => root,
    group => root,
  }
  file { $redis_src_dir:
    ensure => directory,
  } ~>
  file { '/etc/redis':
    ensure => directory,
  } ~>
  file { 'redis-lib':
    ensure => directory,
    path   => '/var/lib/redis',
  } ~>
  file { 'var-redis':
    ensure => directory,
    path   => '/var/redis',
  } ~>
  file { '6379':
    ensure => directory,
    path   => '/var/redis/6379',
  }

  download_file{
  	["${redis_pkg_name}"]:
  	site => 'http://redis.googlecode.com/files',
  	cwd => '/tmp/other-repos',
    unless => "/usr/bin/test -x /etc/init.d/redis_6379", 
  	require => File['/tmp/other-repos', $redis_src_dir],
  	before => Exec['unpack-redis']
  }

  exec { 'unpack-redis':
    command => "tar --strip-components 1 -xzf ${redis_pkg}",
    cwd     => $redis_src_dir,
    path    => '/bin:/usr/bin',
    unless  => "/usr/bin/test -x /etc/init.d/redis_6379",
  }
  exec { 'install-redis':
    command => "make -C ${redis_bin_dir} ; make install -C ${redis_bin_dir}",
    cwd     => $redis_src_dir,
    path    => '/bin:/usr/bin',
    unless  => "/usr/bin/test -x /etc/init.d/redis_6379",
    require => Exec['unpack-redis'],
  }
  exec {'add redis service':
  	command => '/sbin/chkconfig --add ${redis_service};
 		/sbin/chkconfig ${redis_service} on; ',
 	require => Exec['install-redis'],
  }

}