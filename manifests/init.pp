#BEANCOUNTER main puppet

file {'/etc/resolv.conf':
  ensure      => present,
  owner       => 'root',
  group       => 'root',
  mode        => 0644,
  content     => "nameserver 8.8.8.8\nnameserver 8.8.4.4\n",
  links       => follow,
  before      => Exec['/usr/bin/apt-get update'],
}

user { "vagrant":
    ensure => present,
    shell => "/bin/bash",
    home => "/home/vagrant",
}


exec {'/usr/bin/apt-get update':
  before      => Class['elasticsearch'],
}
class {'elasticsearch':
  before      => [
    Class['apache2'], 
    Class['tomcat7']
  ],
}
class {'apache2':
  before 	  => Class['rvm'],
}
class { 'tomcat7':
    jdk => 'openjdk-6-jdk',
}
class { 'kestrel':
  before => Class['tomcat7'] 
}
class { 'redis':
  before => Class['kestrel']
}

class { 'rvm': 
  version => '1.20.12' 
  } -> #and then
file { '/home/vagrant/.rvm':
   ensure => 'link',
   target => '/usr/local/rvm',
} -> #and then
rvm_system_ruby {
  'ruby-1.9.3-p429':
    ensure => 'present',
    default_use => true;
}
#rvm::system_user { vagrant: ; }



