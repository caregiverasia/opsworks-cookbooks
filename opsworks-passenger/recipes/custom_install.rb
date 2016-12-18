bash 'build-and-install-nginx-passenger' do
  code <<-EOF
    passenger-install-nginx-module --auto --prefix=#{node[:nginx][:prefix_dir]} --auto-download --extra-configure-flags="--conf-path='/etc/nginx/nginx.conf'"
  EOF
  not_if { ::File.exist?("#{node[:nginx][:prefix_dir]}/sbin/nginx") }
end

# We are deleting default files packaged with the nginx rpm
file "/etc/nginx/conf.d/default.conf" do
  action :delete
end

file "/etc/nginx/conf.d/example_ssl.conf" do
  action :delete
end
