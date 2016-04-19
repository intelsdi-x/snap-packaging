# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: override this by configuring --provider {provider_name}
CURRENT_DEFAULT_PROVIDER = ENV['VAGRANT_DEFAULT_PROVIDER']
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'parallels'

Vagrant.configure(2) do |config|
  # NOTE: boxes obtained from https://atlas.hashicorp.com/boxcutter
  # packer build source repo: https://github.com/boxcutter
  operating_systems = %w{ centos72 ubuntu1604 }

  operating_systems.each do |os|
    config.vm.define os do |system|
      system.vm.box = "boxcutter/#{os}"
    end

    config.vm.synced_folder "./pkgs", "/packages"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.sudo = true
  end
end

ENV['VAGRANT_DEFAULT_PROVIDER'] = CURRENT_DEFAULT_PROVIDER
