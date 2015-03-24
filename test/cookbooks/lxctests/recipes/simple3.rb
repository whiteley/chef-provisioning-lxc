lxcbrip = %x(ip -o -f inet addr show lxcbr0).split[3].split('/')[0]
chefserverurl = URI::HTTP.build(host: lxcbrip, port: 4545).to_s

node.override[:goiardi][:bin] = 'http://mwhiteley-fastly.s3.amazonaws.com/goiardi-0.9.0-linux-amd64'
node.override[:goiardi][:hostname] = lxcbrip
node.override[:goiardi][:ipaddress] = lxcbrip
node.override[:goiardi][:loglevel] = 'debug'
node.override[:goiardi][:syslog] = false
include_recipe 'goiardi::runit_service'

require 'chef/provisioning'

with_driver 'lxc'

directory '/etc/chef' do
  mode '0755'
  owner 'root'
  group 'root'
end

execute 'openssl genrsa -out client.pem 2048' do
  cwd '/etc/chef'
  creates '/etc/chef/client.pem'
end

file '/etc/chef/knife.rb' do
  content <<-EOF
node_name 'lxctests'
client_key '/etc/chef/client.pem'
chef_server_url "#{chefserverurl}"
  EOF
  mode '0644'
  owner 'root'
  group 'root'
end

file '/tmp/kitchen/cookbooks/lxctests/recipes/files.rb' do
  content <<-EOF
1000.upto(9999).take(#{node['lxctests']['numfiles']}).each do |n|
  file '/tmp/wtf_' + n.to_s do
    content n.to_s
    owner 'root'
    group 'root'
    mode '0644'
  end
end
  EOF
  mode '0644'
  owner 'root'
  group 'root'
end

execute 'knife cookbook upload --all --cookbook-path /tmp/kitchen/cookbooks' do
  cwd '/etc/chef'
end

directory '/home/vagrant/.chef/package_cache' do
  mode '0755'
  owner 'root'
  group 'root'
  recursive true
end

remote_file '/home/vagrant/.chef/package_cache/chef_12.1.2-1_amd64.deb' do
  source 'file:///tmp/vagrant-cache/vagrant_omnibus/chef_12.1.2-1_amd64.deb'
end

with_chef_server chefserverurl,
  client_name: 'lxctests',
  signing_key_filename: '/etc/chef/client.pem'

machine 'simple3' do
  machine_options(
    template: 'download',
    template_options: %w( -d ubuntu -a amd64 -r trusty )
  )
  run_list %w( recipe[lxctests::files] )
end
