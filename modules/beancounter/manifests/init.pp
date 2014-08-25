class beancounter {
  file { '/home/vagrant/.ssh/deploy':
    ensure => present,
    source => 'puppet:///modules/beancounter/deploy',
    owner => 'vagrant',
    mode => '0600'
  }->
  file { '/home/vagrant/.ssh/config':
    ensure => present,
    content => "StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
            Host github.com
            IdentityFile ~/.ssh/deploy",
    owner => 'vagrant',
    mode => '0700'
  }->
  exec { 'clone':
    command => 'git clone git@github.com:xpeppers/XPeppers-Beancounter-2.0.git beancounter && cd beancounter && git checkout v1.8-Final',
    user => 'vagrant',
    cwd => '/home/vagrant',
    creates => '/home/vagrant/beancounter',
    logoutput => true
  }->
  exec { 'build':
    command => 'mvn clean install -DskipTests',
    user => 'vagrant',
    cwd => '/home/vagrant/beancounter',
    timeout => '0',
    logoutput => true
  }->
  exec { 'config deploy':
    command => 'sed "s|192.168.10.10|localhost|" -i bc-deploy-all-dev.sh',
    user => 'vagrant',
    cwd => '/home/vagrant/beancounter/scripts/deploy/remote/dev',
    logoutput => true
  }->
  exec { 'deploy':
    command => 'bash bc-deploy-all-dev.sh',
    user => 'vagrant',
    cwd => '/home/vagrant/beancounter/scripts/deploy/remote/dev',
    logoutput => true
  }
}
