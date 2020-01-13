# package %w(nodejs npm)  do
#   action :nothing
# end

bash 'prepare nodejs package' do
  code <<-EOH
    yum remove -y nodejs npm
    curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
    EOH
  action :run
  not_if 'rpm -qa | grep nodesource '
end
