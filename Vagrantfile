# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "hashicorp/precise64"
    config.vm.hostname = "beancounter-vagrant.xpeppers.com"
    config.vm.network :forwarded_port, guest: 80, host: 8090

    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end

    config.vm.provision :shell, :path => "upgrade-puppet.sh"

    config.vm.provision :puppet do |puppet|
      puppet.options = "--verbose"
      puppet.manifest_file     = "init.pp"
      puppet.module_path     = "modules"
    end
end
