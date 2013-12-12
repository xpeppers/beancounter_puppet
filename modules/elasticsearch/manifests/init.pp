class elasticsearch {
  package{ 'openjdk-6-jdk':
    ensure	=> latest,
  }
  download_file {
  	['elasticsearch-0.19.4.deb']:
  	site => 'http://download.elasticsearch.org/elasticsearch/elasticsearch',
  	cwd => '/tmp/other-repos',
    unless => "/usr/bin/test $(/usr/bin/dpkg -l | grep elasticsearch | cut -d ' ' -f 3) = 'elasticsearch'", 
  	require => File['/tmp/other-repos'],
  	before => Package['elasticsearch']
  } 
  file {'/tmp/other-repos':
    ensure      => 'directory',
    mode   => 755,
  } 

  package {'elasticsearch':
  	provider => dpkg,
    ensure   => present,
 	  source   => '/tmp/other-repos/elasticsearch-0.19.4.deb',    
  } ~>
  file {'/etc/init.d/elasticsearch':
    ensure      => file,
    mode   => 755,
    content     => template('elasticsearch/etc/init.d/elasticsearch/elasticsearch.erb'),
  } ~>
  file {'/usr/share/elasticsearch/bin/elasticsearch':
    ensure      => file,
    mode   => 755,
    content     => template('elasticsearch/usr/share/elasticsearch/bin/elasticsearch.erb'),
  } ~>
  file {'/usr/share/elasticsearch/bin/elasticsearch.in.sh':
    ensure      => file,
    mode   => 755,
    content     => template('elasticsearch/usr/share/elasticsearch/bin/elasticsearch.in.sh.erb'),
  } ~>
  file {'/etc/elasticsearch/elasticsearch.yml':
    ensure      => file,
    mode   => 644,
    content     => template('elasticsearch/etc/elasticsearch/elasticsearch.yml.erb'),
  } ~>
  file {'/etc/elasticsearch/logging.yml':
    ensure      => file,
    mode   => 644,
    content     => template('elasticsearch/etc/elasticsearch/logging.yml.erb'),
  } 
  exec {'add elasticsearch service':
    command => '/sbin/chkconfig --add elasticsearch;
    /sbin/chkconfig elasticsearch on;',
    require => Exec['elasticsearch-0.19.4.deb'] #Package['elasticsearch']
  }

  service { 'elasticsearch':
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => Exec['add elasticsearch service'],
  }
}