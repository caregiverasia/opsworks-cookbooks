execute "nginx.nxensite default" do
  command "/usr/sbin/nxensite default"
  not_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
end
