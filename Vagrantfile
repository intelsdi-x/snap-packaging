# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: override this by configuring --provider {provider_name}
CURRENT_DEFAULT_PROVIDER = ENV['VAGRANT_DEFAULT_PROVIDER']
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'parallels'

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  operating_systems = %w{ centos72 ubuntu1604 }

  operating_systems.each do |os|
    config.vm.define os do |system|
      system.vm.box = "boxcutter/#{os}"
    end

    config.vm.synced_folder "./pkgs", "/packages"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end

ENV['VAGRANT_DEFAULT_PROVIDER'] = CURRENT_DEFAULT_PROVIDER
