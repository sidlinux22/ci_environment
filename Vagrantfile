# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.box = "todo_basebox"
  config.omnibus.chef_version = :latest
 # config.omnibus.chef_version = "10.16.6"
  config.vm.hostname = "TOdo-app"
  config.vm.network :forwarded_port, guest: 3030, host: 3000
  config.vm.network :private_network, ip: "192.168.33.11"
  config.vm.provision :chef_solo do |chef|
  chef.cookbooks_path = "cookbooks"
  chef.log_level = :debug
  #chef.add_recipe "user"
  chef.roles_path = "roles"
  chef.add_role "todo_app"
  chef.provisioning_path = "/home/vagrant/"

  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end
end
end
