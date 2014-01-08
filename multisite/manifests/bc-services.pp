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
file {'/usr/local/beancounter':
  ensure    => directory,
  owner       => 'root',
  group       => 'root',
  mode        => 0775,
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

user { 'deploy':
  ensure => present,
  shell => "/bin/bash",
  home => "/home/deploy",
  managehome => true,
  gid => '1000',
  groups => ['root', 'admin']
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
  before      => Package['openjdk-6-jdk'],
}

package {'openjdk-6-jdk':
  ensure => latest
}
#rvm::system_user { vagrant: ; }



