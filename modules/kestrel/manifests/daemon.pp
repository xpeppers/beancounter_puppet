class daemon {
  download_file {
  	['daemon-0.6.4.tar.gz']:
  	site => 'http://libslack.org/daemon/download',
  	cwd => '/tmp/other-repos',
  	require => File['/tmp/other-repos'],
  	unless => '/usr/bin/test -f /tmp/other-repos/daemon-0.6.4.tar.gz',
  	before => Exec['daemon']
  } 
  # file {'/tmp/other-repos':
  #   ensure      => 'directory',
  #   mode   => 755,
  # } 

  exec {'daemon':
  	command => '/bin/tar xzf daemon-0.6.4.tar.gz &&
  	cd daemon-0.6.4 &&
  	./config &&
  	make && make install PREFIX=/tmp/other-repos/daemon-0.6.4; ',
  	cwd => '/tmp/other-repos',    
  } 
}
