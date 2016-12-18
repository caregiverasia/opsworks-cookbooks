# wget https://www.phusionpassenger.com/latest_stable_tarball -O passenger-5.1.0.tar.gz
# tar -xzvf passenger-5.1.0.tar.gz -C ./
# ./passenger-5.1.0/bin/passenger-install-nginx-module --auto --prefix=/ --auto-download --extra-configure-flags="--conf-path='/opt/nginx/etc/nginx.conf'"

remote_file "/opt/passenger-#{node[:passenger][:version]}.tar.gz" do
  source "https://www.phusionpassenger.com/passenger-#{node[:passenger][:version]}.tar.gz"
  action :create
  owner "root"
  group "root"
  not_if { ::File.exist?("/usr/sbin/nginx") }
end

bash 'build-and-install-nginx-passenger' do
  cwd "/opt"
  code <<-EOF
    tar -xzvf passenger-#{node[:passenger][:version]}.tar.gz
    mv passenger-#{node[:passenger][:version]}.tar.gz passenger
    cd passenger && ./bin/passenger-install-nginx-module --auto --prefix=/usr --auto-download --extra-configure-flags="--conf-path='/etc/nginx/nginx.conf'"
  EOF
  not_if { ::File.exist?("/usr/sbin/nginx") }
end

# We are deleting default files packaged with the nginx rpm
file "/etc/nginx/conf.d/default.conf" do
  action :delete
end

file "/etc/nginx/conf.d/example_ssl.conf" do
  action :delete
end
