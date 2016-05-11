# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: override this via the option --provider {provider_name}
ENV["VAGRANT_DEFAULT_PROVIDER"] = "parallels"

Vagrant.configure(2) do |config|
  # Global settings:
  config.vm.synced_folder "./artifacts", "/artifacts"

  config.vm.provider "parallels" do |vm|
    vm.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  end

  # NOTE: these boxes are not intended to test packages.
  build_systems = {
    redhat: "boxcutter/centos72",
    debian: "boxcutter/ubuntu1604",
  }

  build_systems.each do |os, box|
    config.vm.define os do |system|
      system.vm.box = box

      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "build.yml"
        ansible.sudo = true
      end
    end
  end

  # NOTE: test boxes obtained from https://atlas.hashicorp.com/boxcutter
  # packer build source repo: https://github.com/boxcutter
  operating_systems = %w{ centos67 centos72 ubuntu1604 ubuntu1404 }

  operating_systems.each do |os|
    config.vm.define os do |system|
      system.vm.box = "boxcutter/#{os}"

      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "deploy.yml"
        ansible.sudo = true
      end

      if Vagrant.has_plugin?("vagrant-serverspec")
        config.vm.provision :serverspec do |spec|
          spec.pattern = "spec/*_spec.rb"
        end
      end
    end
  end
end
