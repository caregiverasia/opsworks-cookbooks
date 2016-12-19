opsworks_passenger_nginx_server_conf "security" do
  source "security.conf.erb"
end

cookbook_file "#{node[:nginx][:prefix_dir]}/html/maintenance.html" do
  source "maintenance.html"
  group "root"
  owner "root"
  mode 0644
end
include_recipe "opsworks-passenger::maintenance"

template node[:ruby_wrapper][:install_path] do
  source "ruby-wrapper.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  variables(
      :ruby_binary => node[:ruby_wrapper][:ruby_binary],
      :extra_env_vars => node[:ruby_wrapper][:extra_env_vars]
  )
end

opsworks_passenger_nginx_conf "passenger" do
  source "passenger.conf.erb"
  variables(
      :passenger_conf => node[:passenger][:conf]
  )
end

template "#{node[:nginx][:dir]}/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe "nginx::service"
service "nginx" do
  action [ :enable, :start ]
end

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not a Rails app")
    next
  end

  case deploy[:database][:type]
  when "mysql"
    include_recipe "mysql::client_install"
  when "postgresql"
    include_recipe "opsworks_postgresql::client_install"
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_rails do
    deploy_data deploy
    app application
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_passenger_nginx_app application do
    deploy deploy
  end

end
