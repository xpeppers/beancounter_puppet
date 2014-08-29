class beancounter_deploy {
  file { '/home/deploy/.ssh/deploy':
    ensure => present,
    source => 'puppet:///modules/beancounter_deploy/deploy',
    links => 'follow',
    owner => 'deploy',
    mode => '0600'
  }->
  file { '/home/deploy/.ssh/config':
    ensure => present,
    content => "StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
            Host github.com
            IdentityFile ~/.ssh/deploy",
    owner => 'deploy',
    mode => '0700'
  }->
  exec { 'sudo-as-deploy':
    command => "echo 'deploy  ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers",
    logoutput => 'on_failure'
  }->
  exec { 'clone':
    command => 'git clone git@github.com:xpeppers/XPeppers-Beancounter-2.0.git beancounter && cd beancounter && git checkout v1.8-Final',
    user => 'deploy',
    cwd => '/home/deploy',
    creates => '/home/deploy/beancounter',
    logoutput => true
  }->
  exec { 'build':
    command => 'mvn clean install -DskipTests',
    user => 'deploy',
    cwd => '/home/deploy/beancounter',
    timeout => '0',
    logoutput => true
  }

  #FIXME Fix beancounter scripts to make deploy work during provisioning
  #
  #exec { 'config deploy':
  #  command => 'sed "s|192.168.10.10|localhost|" -i bc-deploy-all-dev.sh',
  #  user => 'deploy',
  #  cwd => '/home/deploy/beancounter/scripts/deploy/remote/dev',
  #  logoutput => true
  #}->
  #exec { 'deploy':
  #  command => 'bash bc-deploy-all-dev.sh',
  #  user => 'deploy',
  #  cwd => '/home/deploy/beancounter/scripts/deploy/remote/dev',
  #  logoutput => true
  #}
}
