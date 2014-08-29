# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "local", primary: true do |local|
    local.vm.box = "beancounter"
    local.vm.box_url = "http://dl.dropbox.com/u/155090965/vagrant-ubuntu_server_12.04LTS_i386.box"
    local.vm.provision :shell, :inline => "apt-get update -y --fix-missing"

    local.vm.hostname = "beancounter-blade.xpeppers.com"
    local.vm.network :forwarded_port, guest: 80, host: 8080
    local.vm.network :forwarded_port, guest: 22, host: 2224

    local.vm.network :private_network, ip: "192.168.10.10"

    # Create a public network, which generally matched to bridged network.
    # Bridged networks make the machine appear as another physical device on
    # your network.
    #config.vm.network :public_network

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # config.vm.synced_folder "../data", "/vagrant_data"

    local.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      # vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", "4096"]
    end

    local.vm.provision :puppet do |puppet|
      # puppet.options = "--verbose --debug"
      puppet.module_path     = "modules"
      puppet.manifests_path    = "manifests"
      puppet.manifest_file     = "init.pp"
    end
  end
end
