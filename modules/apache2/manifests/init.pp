# -*- coding: utf-8 -*-
# apache2 - init.pp

class apache2 {
  if $hardwaremodel == 'x86_64' {
    $passenger_version = '4.0.27'
    $template_demo_conf = "demo.conf.64.erb"
  } else {
    $passenger_version = "4.0.5"
    $template_demo_conf = "demo.conf.erb"
  }
  $passenger_tar = "passenger-$passenger_version.tar.gz"


  package {'apache2':
    ensure      => present,
    before      => File['/etc/apache2/ports.conf'],
  }

  package {['libcurl4-openssl-dev',
            'libssl-dev',
            'zlib1g-dev',
            'apache2-threaded-dev',
            'libapr1-dev',
            'libaprutil1-dev',
            'librack-ruby',
            'rubygems',
            'ruby-rack',
            'libjs-prototype',
            'libapache2-mod-python']:
    ensure      => present,
    require     => Package['apache2'],
  }

  # 2) gem1.9.3 install bundler

  service { 'apache2':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => [
                     Package['apache2'],
                     File['/opt/demo'],
                     File['/opt/demo/public'],
                     Exec['Load passenger apache2 module'],
                   ],
    subscribe   => [
                     File['/etc/apache2/ports.conf'],
                     File['/etc/apache2/sites-available/demo.conf'],
                   ],
  }

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  exec { 'Installing gem passenger':
    command     => "gem1.9.3 install passenger --version '$passenger_version'",
    require     => Package['apache2'],
    unless      => "/usr/bin/test $(gem1.9.3 list --local | grep passenger | cut -d ' ' -f 1) = 'passenger'"
  }

  exec { 'Installing gem bundler':
    command     => "gem1.9.3 install bundler --version '1.3.5'",
    unless      => "/usr/bin/test $(gem1.9.3 list --local | grep passenger | cut -d ' ' -f 1) = 'passenger'",
    require     => Exec['Installing gem passenger'],
  }

  file { "/var/lib/gems/1.9.1/gems/$passenger_tar":
    ensure      => present,
    source      => "puppet:///modules/apache2/$passenger_tar",
    require     => Exec['Installing gem passenger'],
  }

  exec { 'Load passenger apache2 module':
      cwd       => '/var/lib/gems/1.9.1/gems/',
      command   => "tar zxf $passenger_tar",
      require   => File["/var/lib/gems/1.9.1/gems/$passenger_tar"],
  }

  exec { 'Disable default apache site':
    command     => 'a2dissite default',
    onlyif      => 'test -f /etc/apache2/sites-enabled/000-default',
    require     => Package['apache2'],
    notify      => Service['apache2'];
  }

  file { ['/opt/demo', '/opt/demo/public']:
    ensure      => directory,
    owner       => 'www-data',
    group       => 'www-data',
    mode        => '0777'
  }

  file { '/etc/apache2/sites-available/demo.conf':
    ensure  => file,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    content => template("apache2/etc/apache2/sites-available/$template_demo_conf"),
    require => File['/etc/apache2/ports.conf'],
  }

  file { '/etc/apache2/sites-enabled/demo.conf':
    ensure  => link,
    target  => '/etc/apache2/sites-available/demo.conf',
    require => File['/etc/apache2/sites-available/demo.conf'],
    notify  => Service['apache2'];
  }

  file {'/etc/apache2/ports.conf':
    ensure      => file,
    content     => template('apache2/etc/apache2/ports.conf.erb'),
  }
}
