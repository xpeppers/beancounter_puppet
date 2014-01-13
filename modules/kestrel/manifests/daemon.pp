class daemon {
  download_file {
    ['daemon-0.6.4.tar.gz']:
    site => 'http://libslack.org/daemon/download',
    cwd => '/tmp/other-repos',
    require => File['/tmp/other-repos'],
    before => Exec['daemon'],
    unless => '/usr/bin/test -f /usr/local/bin/daemon',
  }
  exec {'daemon':
    command => '/bin/tar xzf daemon-0.6.4.tar.gz &&
    cd daemon-0.6.4 &&
    ./config &&
    make PREFIX=/tmp/other-repos/daemon-0.6.4; ',
    cwd     => '/tmp/other-repos',
    require => Exec['daemon-0.6.4.tar.gz'],
    unless => '/usr/bin/test -f /usr/local/bin/daemon',
  }
  exec {'daemon install':
    command => '/usr/bin/make install',
    cwd     => '/tmp/other-repos/daemon-0.6.4',
    require => Exec['daemon'],
    unless => '/usr/bin/test -f /usr/local/bin/daemon',
  }
}
