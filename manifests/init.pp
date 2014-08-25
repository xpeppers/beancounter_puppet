#BEANCOUNTER main puppet

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

define download_file(
        $site="",
        $cwd="",
        $unless="/usr/bin/test 1 = 1", #sicuramente vero
        $creates="",
        $require="",
        $before="") {

    exec { $name:
        command => "/usr/bin/wget ${site}/${name}",
        cwd => $cwd,
        creates => "${cwd}/${name}",
        require => $require,
        before => $before,
        logoutput => "on_failure",
        timeout => 10000,
        unless => $unless
    }
}

file {'/etc/resolv.conf':
  ensure      => present,
  owner       => 'root',
  group       => 'root',
  mode        => 0644,
  content     => "nameserver 8.8.8.8\nnameserver 8.8.4.4\n",
  links       => follow
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

package {
  [
    'git-core',
    'ntp',
    'ntpdate',
    'chkconfig',
    'openjdk-7-jdk',
    'maven'
  ]:
  ensure => present
}->
exec { 'set-java-7':
  command => 'update-alternatives --set java /usr/lib/jvm/java-7-openjdk-i386/jre/bin/java'
}->
class {'elasticsearch':
  package_url  => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.13.deb',
  before      => [
    Class['apache2'],
    Class['tomcat7']
  ]
}

class ruby {
  class { 'rvm':
    version => '1.20.12'
  } ->
  file { '/home/vagrant/.rvm':
    ensure => 'link',
    target => '/usr/local/rvm',
  } ->
  file { '/home/deploy/.rvm':
    ensure => 'link',
    target => '/usr/local/rvm',
  } ->
  rvm_system_ruby {
    'ruby-1.9.3-p429':
      ensure => 'present',
      default_use => true;
  } ->
  rvm_gem {
      "ruby-1.9.3-p429/bundler": ensure => '1.3.5';
      "ruby-1.9.3-p429/passenger": ensure => '4.0.5';
  }
}
class { 'ruby': }

class {'apache2':
  require => Class['ruby']
}

class { 'tomcat7':
    jdk => 'openjdk-7-jdk',
}

class { 'kestrel':
  before => Class['tomcat7'] 
}

class { 'redis':
  before => Class['kestrel']
}
