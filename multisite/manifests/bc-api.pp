#BEANCOUNTER main puppet

file {'/etc/resolv.conf':
  ensure      => present,
  owner       => 'root',
  group       => 'root',
  mode        => 0644,
  content     => "nameserver 8.8.8.8\nnameserver 8.8.4.4\n",
  links       => follow,
  before      => Exec['apt-get update'],
}

file { '/sbin/insserv':
   ensure => 'link',
   target => '/usr/lib/insserv/insserv',
}
user { 'vagrant':
  ensure => present,
  shell => '/bin/bash',
  home => '/home/vagrant',
  managehome => true,
}
group { 'tomcat7':
  ensure => present
}
user { 'deploy':
  ensure => present,
  shell => "/bin/bash",
  home => "/home/deploy",
  managehome => true,
  gid => '1000',
  groups => ['root', 'tomcat7', 'admin']
}
ssh_authorized_key{ "deploy": 
  user => "deploy",
  ensure => present, 
  type => "ssh-rsa", 
  key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDiGqNDqOUorSKA8o5DpfZiP19DvSOdSRURVlcw3KO2mLwrrGQnHlw1d4GBqNXJy9NtWURG9cvkGWsF4KO/EYiCT8/Oo+lUbO0e5i+zECtKzoDPHqNsl3z/qgWyeldxyO2yDQCPbYzcliqhaYO2htk5tC4VHuuQyHl24GyVEHN/zOKlevraVyj0hTdfGtMv906E5LsGgNgoSfyn9zy3TGN/aIXirLU8oB+57IELTYxJAnPN3iWQZPTr7gIx5kZEoIyavRswytUSQ4b8m0dIZFBHuJrz0BPpdzkYBVMYaEIAjdOyIYBE6Wh2evUxcjab8FdbD28ONeHxT9Lth7b7Plnz", 
  name => "deploy-public-key" 
 } 

exec {'apt-get update':
  command => '/usr/bin/apt-get update --fix-missing',
  before      => Package['apache2'],
}
package{ 'openjdk-6-jdk':
    ensure  => latest,
    before  => Class['tomcat7']
}
class {'apache2':
  before 	  => Class['rvm'],
}
class { 'tomcat7':
    jdk => 'openjdk-6-jdk',
}

class { 'rvm': 
  version => '1.20.12' 
  } -> #and then
file { '/home/vagrant/.rvm':
   ensure => 'link',
   target => '/usr/local/rvm',
} -> #and then
file { '/home/deploy/.rvm':
   ensure => 'link',
   target => '/usr/local/rvm',
} -> #and then
rvm_system_ruby {
  'ruby-1.9.3-p429':
    ensure => 'present',
    default_use => true;
}



