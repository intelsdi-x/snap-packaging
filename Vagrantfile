# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: override this via the option --provider {provider_name}
ENV["VAGRANT_DEFAULT_PROVIDER"] = "parallels"

puts "Plugin missing: please run `vagrant plugin install vagrant-serverspec`." unless Vagrant.has_plugin? "vagrant-serverspec"

Vagrant.configure(2) do |config|
  # Global settings:
  config.vm.synced_folder "./artifacts", "/artifacts"

  config.vm.provider "parallels" do |vm|
    vm.linked_clone = true
    vm.update_guest_tools = true
  end

  # NOTE: these boxes are not intended to test packages.
  build_systems = {
    redhat: "boxcutter/centos72",
    debian: "ubuntu1604",
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
  operating_systems = %w{ centos67 centos72 ubuntu1604 ubuntu1404 ubuntu1204 osx1011 }

  operating_systems.each do |os|
    config.vm.define os do |system|
      # osx built from boxcutter repo since the box is not publicly available
      if os =~ /^osx/ then
        system.vm.box = os
      elsif os =~ /^ubuntu/ then
        system.vm.box = os
      else
        system.vm.box = "boxcutter/#{os}"
      end

      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "deploy.yml"
        ansible.sudo = true

        ansible.extra_vars = {
          snap_version: ENV['SNAP_VERSION'] || '0.16.1'
        }
      end

      config.vm.provision :serverspec do |spec|
        spec.pattern = "spec/snap_spec.rb"
      end if Vagrant.has_plugin?("vagrant-serverspec")
    end
  end

end
