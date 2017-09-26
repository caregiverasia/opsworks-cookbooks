node[:deploy].each do |application, deploy|
    node.normal[:deploy][application][:symlink_before_migrate].clear
end
