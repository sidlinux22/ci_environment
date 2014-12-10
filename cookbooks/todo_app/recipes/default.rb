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
