ci_environment
==============
[![Build Status](https://travis-ci.org/sidlinux22/ci_environment.svg?branch=master)](https://travis-ci.org/sidlinux22/ci_environment)

#### Deploy a Rails Application with Chef-Solo

#### Design:
![alt tag](https://github.com/sidlinux22/ToDoAPP/blob/master/log/ci-arc.png)

#### Component Stack:

* Building development environments: Vagrant,Virtual Box
* App framework : ROR
* Version Control : GIT
* Configuration Management tool : CHEF
* Continuous Integration : TRAVIS-CI




#### App detail:
* APP Name : TODO
* Farmework : ROR
* Git repo : https://github.com/sidlinux22/ToDoAPP
* Read Me : https://github.com/sidlinux22/ToDoAPP/blob/master/README.md


### Configuration of Development Enviroment

1. Download and install VirtualBox <br>
[ https://www.virtualbox.org/wiki/Downloads Download VirtualBox]<br>
2.Download and install Vagrant<br>
[ http://downloads.vagrantup.com/ Download Vagrant]
This is a script use to install vagrant 
<pre>
#! /bin/bash
echo "Installing version v.1.2.1"
cd /tmp/
wget http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/vagrant_1.2.2_x86_64.rpm
rpm -ivh vagrant_1.2.2_x86_64.rpm
</pre>

3. Creating a Vagrant VM in the project directory with :
 <pre> vagrant box add TOdo-app
  vagrant init </pre>

4. Configure vagrant file 

<pre>

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "todo_basebox"
  config.omnibus.chef_version = :latest
 #config.omnibus.chef_version = "10.16.6"
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
end
end
</pre>

5. Initializing Chef-solo

<pre> mkdir todo_app </pre>
<pre> cd todo_app</pre>
* Install Librarian-Chef
<pre> gem install librarian-chef </pre>
<pre> librarian-chef init </pre>

* Specifying all  dependencies in Cheffile 
<pre>
L-IDC1X4DKQ2-M:todo_app sshar43$ cat Cheffile | egrep -v "(^#.*|^$)"
site 'https://supermarket.getchef.com/api/v1'
cookbook 'application_ruby'
cookbook 'ruby_build'
</pre>
* Pull  community cookbooks with Librarian
<pre> librarian-chef install </pre>

* Community cookbooks used

application  
https://github.com/poise/application

application_ruby
https://github.com/poise/application_ruby


