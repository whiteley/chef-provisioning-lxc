include_recipe 'lxctests::install_lxc'

package 'git' do
  action :nothing
end.run_action(:install)

if node['lxctests']['use_chef_provisioning_head']
  git '/tmp/chef-provisioning' do
    repository 'https://github.com/chef/chef-provisioning.git'
    action :nothing
  end.run_action(:sync)

  execute 'build chef-provisioning' do
    command 'rake build'
    cwd '/tmp/chef-provisioning'
    creates '/tmp/chef-provisioning/pkg'
    environment 'PATH' => "/opt/chef/embedded/bin:#{ENV['PATH']}"
    action :nothing
  end.run_action(:run)

  chef_gem 'chef-provisioning' do
    source '/tmp/chef-provisioning/pkg/chef-provisioning-0.19.gem'
    compile_time true
  end
else
  chef_gem 'chef-provisioning' do
    compile_time true
  end
end

if node['lxctests']['use_chef_provisioning_lxc_head']
  git '/tmp/chef-provisioning-lxc' do
    repository 'https://github.com/chef/chef-provisioning-lxc.git'
    action :nothing
  end.run_action(:sync)

  execute 'build chef-provisioning-lxc' do
    command 'rake build'
    cwd '/tmp/chef-provisioning-lxc'
    creates '/tmp/chef-provisioning-lxc/pkg'
    environment 'PATH' => "/opt/chef/embedded/bin:#{ENV['PATH']}"
    action :nothing
  end.run_action(:run)

  chef_gem 'chef-provisioning-lxc' do
    source '/tmp/chef-provisioning-lxc/pkg/chef-provisioning-lxc-0.6.1.gem'
    compile_time true
  end
else
  chef_gem 'chef-provisioning-lxc' do
    compile_time true
  end
end
