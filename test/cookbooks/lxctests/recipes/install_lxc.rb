include_recipe 'apt'
include_recipe 'build-essential'

# Ubuntu 14+ ships with fresh enough LXC
if node['platform'] == 'ubuntu' && node['platform_version'].to_i == 12
  apt_repository 'ppa:ubuntu-lxc/stable' do
    action :nothing
  end.run_action(:add)
end

package 'lxc support packages' do
  package_name %w( bridge-utils cgroup-bin haveged lxc-dev lxc-templates )
  action :nothing
end.run_action(:upgrade)
