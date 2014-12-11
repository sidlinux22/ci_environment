ci_environment
==============
[![Build Status](https://travis-ci.org/sidlinux22/ci_environment.svg?branch=master)](https://travis-ci.org/sidlinux22/ci_environment)

#### Deploy  Rails Application with Chef-Solo

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

```
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
```
## Initializing Chef-solo

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

* Community cookbooks used:
1) application [https://github.com/poise/application]
2) application_ruby[https://github.com/poise/application_ruby]


### Create  USER cookbook 
Create/Configue the user cookbook to create a new user that will run deploy artifact and run application
<pre> knife cookbook create user </pre>
Setting user attribute 
```
L-IDC1X4DKQ2-M:user sshar43$ cat attributes/default.rb
default[:use][:name]  = "app"
default[:user][:password] = "$1$JJsvHslV$szsCjVEroftprNn4JHtDi."
default[:user][:login_shell] = "/bin/bash"
default[:user][:description] = "Adding user.."
default[:user][:username] = "app"
default[:user][:home] = "/home/app"
default[:user][:authorized_keys] = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5njJW9BvU+fXPa9wdglUgn/tm5FfCAX9l+oJXSq+ABRxm32yTnigIQYhFyFSPUdVLqYQhz3hOQN0g2X2tmFKuDpF6gNk39SVxl9IQlPwpLwbT/WefP/ISG2su72UYmvSeF9DcKNLaMAMYiJgftolu86wQ2lokXmI6IGmWatniTiokeHCjUHI0Bt46KXeHEh9NWeifwnmUtpXyxKV+Dv3lXNHbpLKLftGf42TraF6Zs0waaGuY+b0jNmQPL6qQFwtzrH5kuGUI5NHpHs/wuz5hrydnF2LIWD6ChXj63/PcrzBc22BE6XsrjCLWML91nTKaIODLaPSemcqQ5Vd8Kj4B sshar43@L-IDC21EDRVG-M.local"
```
* Create recipe to add user with set attribute

```
IDC1X4DKQ2-M:user sshar43$ cat recipes/default.rb  | egrep -v "(^#.*|^$)"
user node[:user][:name] do
  comment "#{node[:user][:name]} User"
  home "/home/#{node[:user][:name]}"
  shell "/bin/bash"
  password node[:user][:password]
  supports manage_home: true
end
user "#{node[:user][:username]}" do
  comment node[:user][:description]
  supports :manage_home => true
  home node[:user][:home]
  if node[:user][:system_user] == 'true'
    system true
    shell '/bin/false'
  else
    shell node[:user][:login_shell] unless node[:user][:login_shell].empty?
  end
end
directory "#{node[:user][:home]}" do
  owner node[:user][:username]
  group node[:user][:username]
end
directory "#{node[:user][:home]}/.ssh" do
  owner node[:user][:username]
  group node[:user][:username]
  mode 0700
end
file "#{node[:user][:home]}/.ssh/authorized_keys" do
  owner node[:user][:username]
  group node[:user][:username]
  mode 0600
  content node[:user][:authorized_keys]
end
```

### Create new cookbook  "todo_app" to deploy Ruby web applications

we define our application using application resource provided by application cookbook
<pre> knife cookbook create todo_app </pre>
* Recipe to build/deploy app

```
L-IDC1X4DKQ2-M:cookbooks sshar43$ cat  todo_app/recipes/default.rb | egrep -v "(^#.*|^$)"
  include_recipe 'ruby_build'
  ruby_build_ruby '1.9.3-p362' do
    prefix_path '/usr/local/'
    environment 'CFLAGS' => '-g -O2'
    action :install
  end
  gem_package 'bundler' do
    version '1.2.3'
    gem_binary '/usr/local/bin/gem'
    options '--no-ri --no-rdoc'
  end
  application 'todo_app' do
    owner 'app'
    group 'app'
    path '/home/app'
    revision 'v0.1'
    action :force_deploy
    environment 'RAILS_ENV' => 'development'
    repository 'git://github.com/sidlinux22/ToDoAPP.git'
    rails do
      bundle install
      bundler true
    end
    unicorn do
      worker_processes 2
    end
  end
```  


* Cookbook depends on:

<pre>
depends 'application'
depends 'runit'
depends 'ruby_build'
depends 'user'
depends 'application_ruby'
</pre>


#### ROLE
```
L-IDC1X4DKQ2-M:todo_app sshar43$ cat roles/todo_app.rb
name "todo_app"
run_list(
   "recipe[user]",
   "recipe[todo_app::default]"
)
```


#### Deployment to Vagrant VM

* git clone https://github.com/sidlinux22/ci_environment.git
* Start VM by running
 <pre> vagrant up </pre>
When this command is  finised we will have a VM with TOdo app deployed on it.

#### Deployment on local machine using Chef Solo
* create a Chef configuration file
```
root = File.expand_path(File.dirname(__FILE__))

file_cache_path    "/var/chef/cache"
file_backup_path   "/var/chef/backup"
cookbook_path root + '/cookbooks'
if Chef::VERSION.to_f < 11.8
  role_path root + '/roles'
else
  role_path root + '/roles'
end
log_level :debug
verbose_logging    false

encrypted_data_bag_secret nil
```
* JSON config
```
node.json
{
  "run_list": [
    "role[todo_app]"
  ]
}
```
<pre> git clone https://github.com/sidlinux22/ci_environment.git </pre>
<pre>sudo chef-solo -j node.json -c solo.rb </pre>


