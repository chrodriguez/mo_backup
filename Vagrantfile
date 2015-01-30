# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define 'vm', primary: true do |app|
    app.vm.hostname = "backup.vagrant.desarrollo.unlp.edu.ar"
    app.omnibus.chef_version = "11.16.4"
    app.vm.box = "chef/ubuntu-14.04"
    app.vm.network :private_network, ip: "10.100.10.2"
    app.berkshelf.enabled = true
    app.vm.provision :chef_solo do |chef|
      #chef.data_bags_path = './sample/data_bags'
      #chef.environments_path = "sample/environments"
      #chef.environment = "staging"
      #chef.encrypted_data_bag_secret_key_path = 'sample/.chef/data_bag_key'
      chef.json = {
      }
      chef.run_list = [
        "recipe[mo_backup::install]"
      ]
    end
  end
end
