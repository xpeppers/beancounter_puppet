class rvm($version=undef, $install_rvm=true) {
  stage { 'rvm-install': before => Stage['main'] }

  if $install_rvm {
  	exec {'apt-get-update':
  		command => '/usr/bin/apt-get update',  
	}
    class {
      'rvm::dependencies': stage => 'rvm-install';
      'rvm::system':       stage => 'rvm-install', version => $version;
    }
  }
}