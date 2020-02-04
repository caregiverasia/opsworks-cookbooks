execute "nginx.nxensite default" do
  command "/usr/sbin/nxensite default"
  if restart
    notifies :reload, "service[nginx]"
  end
  not_if do ::File.symlink?("#{node[:nginx][:dir]}/sites-enabled/default") end
end
