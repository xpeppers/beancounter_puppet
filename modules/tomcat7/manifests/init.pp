class tomcat7 (
    $enable = true,
    $ensure = running,
    $http_port = 8080,
    $https_port = 8443,
    $jdk = 'default',
    $install_admin = true,
) {
  $jdk_package = "${jdk}"

  package { 'tomcat7':
    ensure => installed,
    require => [
      Package[$jdk_package],
      Package['authbind'],
      Package['libtcnative'],
    ],
  }
  package { 'libtcnative':
    name => 'libtcnative-1',
  }

  package { 'authbind':
  }

  # file { '/etc/tomcat7/server.xml':
  #    owner => 'root',
  #    require => Package['tomcat7'],
  #    notify => Service['tomcat7'],
  #    content => template('tomcat7/server.xml.erb'),
  # }

  service { 'tomcat7':
    ensure => $ensure,
    enable => $enable,
    require => [ 
      Package['tomcat7'],
    ]
  }   

  # Tomcat must started as last service
  exec { 'update-rc':
    command => "/usr/sbin/update-rc.d -f tomcat7 remove; /usr/sbin/update-rc.d tomcat7 defaults 99",
    cwd => "/etc/init.d",
    require => [
      Service['tomcat7'],
    ]
  }

}