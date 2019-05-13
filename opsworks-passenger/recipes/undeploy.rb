#
# Cookbook Name:: opsworks-passenger
# Recipe:: undeploy

include_recipe "nginx::service"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping opsworks-passenger::undeploy application #{application} as it is not an Rails app")
    next
  end

  link "/etc/nginx/sites-enabled/#{application}" do
    action :delete
    only_if do
      ::File.exists?("/etc/nginx/sites-enabled/#{application}")
    end
    notifies :reload, "service[nginx]", :delayed
  end

  file "/etc/nginx/sites-available/#{application}" do
    action :delete
    only_if do
      ::File.exists?("/etc/nginx/sites-available/#{application}")
    end
  end

  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete
    only_if do
      File.exists?("#{deploy[:deploy_to]}")
    end
  end
end
