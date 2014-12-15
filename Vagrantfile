# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.define 'lb', primary: true do |app|
    app.vm.hostname = "proxy.vagrant.desarrollo.unlp.edu.ar"
    app.omnibus.chef_version = :latest
    app.vm.box = "cespi/ubuntu-12.04-upgraded"
    app.vm.box_url = "http://desarrollo.unlp.edu.ar/ubuntu-12.04-upgraded.box"
    app.vm.network :private_network, ip: "10.100.8.2"
    app.berkshelf.enabled = true
    app.vm.provision :chef_solo do |chef|
      chef.data_bags_path = './sample/data_bags'
      chef.environments_path = "sample/environments"
      chef.environment = "staging"
      chef.encrypted_data_bag_secret_key_path = 'sample/.chef/data_bag_key'
      chef.json = {
      }
      chef.run_list = [
        "recipe[mo_server_reverse_proxy_cache::from_databag]",
        "recipe[mo_server_reverse_proxy_cache::nginx]"
      ]
    end
  end
end
