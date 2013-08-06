class kestrel {
  require daemon

  download_file {
  	['kestrel-2.4.1.zip']:
  	site => 'http://robey.github.io/kestrel/download/',
  	cwd => '/tmp/other-repos',
  	require => [
  		File['/tmp/other-repos'],
  		File['/var/run/kestrel'],
  		Package['unzip']
  		],
  	unless => "/usr/bin/test -x /etc/init.d/kestrel",
  	before => Exec['kestrel']
  } 

  exec {'kestrel':
  	command => '/usr/bin/unzip /tmp/other-repos/kestrel-2.4.1.zip;
    /bin/cp -r /tmp/other-repos/kestrel-2.4.1 /usr; ',
  	cwd => '/tmp/other-repos',
  	require =>  File['/var/log/kestrel'],    
  } -> 
  file {'/etc/init.d/kestrel':
    ensure      => file,
    mode   => 755,
    content     => template('kestrel/etc/init.d/kestrel.erb'),
  } ->
  exec {'add kestrel service':
  	command => '/sbin/chkconfig --add kestrel;
 		/sbin/chkconfig kestrel on; '
  }

  package { 'unzip':
  	ensure => present
  }

  service { 'kestrel':
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => Exec['add kestrel service'],
  }

  file {'/var/log/kestrel':
    ensure      => 'directory',
    mode   => 777,
  }
  file {'/var/run/kestrel':
    ensure      => 'directory',
    mode   => 777,
  }
}
