package 'nodejs' do
  action :nothing
end

bash 'prepare nodejs package' do
  code <<-EOH
    yum remove -y nodejs
    curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
    EOH
  action :run
  notifies :install, 'package[nodejs]', :immediately
  not_if 'rpm -qa | grep nodesource '
end
