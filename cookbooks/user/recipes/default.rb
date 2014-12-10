#node.set[:user][:home] = node[:user][:home_directory].empty? ? "/home/#{node[:user][:username]}" : node[:user][:home_directory]
#Add user for deploying app
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
