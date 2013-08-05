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
  }
  file { '/etc/redis':
    ensure => directory,
  }
  file { 'redis-lib':
    ensure => directory,
    path   => '/var/lib/redis',
  }


  download_file{
  	["${redis_pkg_name}"]:
  	site => 'http://redis.googlecode.com/files',
  	cwd => '/tmp/other-repos',
    unless => "/usr/bin/test -f ${redis_pkg}", 
  	require => File['/tmp/other-repos'],
  	before => Exec['unpack-redis']
  }
  # exec { 'get-redis-pkg':
  #   command => "/usr/bin/wget --output-document ${redis_pkg} http://redis.googlecode.com/files/${redis_pkg_name}",
  #   unless  => "/usr/bin/test -f ${redis_pkg}",
  #   require => File[$redis_src_dir],
  # }

  file { 'redis-cli-link':
    ensure => link,
    path   => '/usr/local/bin/redis-cli',
    target => "${redis_bin_dir}/bin/redis-cli",
  }
  exec { 'unpack-redis':
    command => "tar --strip-components 1 -xzf ${redis_pkg}",
    cwd     => $redis_src_dir,
    path    => '/bin:/usr/bin',
    unless  => "/usr/bin/test -f ${redis_src_dir}/Makefile",
  }
  exec { 'install-redis':
    command => "make && make install PREFIX=${redis_bin_dir}",
    cwd     => $redis_src_dir,
    path    => '/bin:/usr/bin',
    unless  => "/usr/bin/test $(${redis_bin_dir}/bin/redis-server --version | cut -d ' ' -f 1) = 'Redis'",
    require => Exec['unpack-redis'],
  }
  exec {'add redis service':
  	command => '/sbin/chkconfig --add ${redis_service};
 		/sbin/chkconfig ${redis_service} on; ',
 	require => Exec['install-redis'],
  }

}