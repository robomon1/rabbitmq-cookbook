#
# Cookbook Name:: rabbitmq
# Recipe:: do_setup_monitoring
#
# Copyright 2012, Ryan J. Geyer <me@ryangeyer.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Hack sudoers to allow the rabbitmq user to run /usr/sbin/rabbitmqctl
# rabbitmq ALL=NOPASSWD: /usr/sbin/rabbitmqctl

rightscale_enable_collectd_plugin "exec"

rightscale_marker :begin

cookbook_file "/etc/sudoers.d/rabbitmq_not_requiretty" do
  backup false
  source "rabbitmq_not_requiretty"
  mode 00440
end

sudo "rabbitmq" do
  user "rabbitmq"
  commands ["/usr/sbin/rabbitmqctl"]
  host "ALL"
  nopasswd true
end

# Add the rabbitmq executable to node[:rightscale][:collectd_lib] /plugins/rabbitmq
directory ::File.join(node[:rightscale][:collectd_lib], 'plugins')

cookbook_file ::File.join(node[:rightscale][:collectd_lib], 'plugins', 'rabbitmq') do
  backup false
  source "rabbitmq.rb"
  mode 00755
end

# template the collectd rabbitmq conf file
template ::File.join(node[:rightscale][:collectd_plugin_dir], 'rabbitmq.conf') do
  backup false
  source "rabbitmq-collectd.conf.erb"
  notifies :restart, resources(:service => "collectd") # This will probably only work on RightScale when this is run in the boot runlist with rs_utils::setup_monitoring
end

rightscale_marker :end