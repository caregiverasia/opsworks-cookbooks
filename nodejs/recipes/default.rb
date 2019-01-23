bash 'prepare nodejs package' do
  code <<-EOH
    yum remove -y nodejs
    curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
    yum install -y nodejs
    EOH
  action :run
  not_if 'rpm -qa | grep nodesource '
end
