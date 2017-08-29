###
# This is the place to override the deploy cookbook's default attributes.
#
# Do not edit THIS file directly. Instead, create
# "deploy/attributes/customize.rb" in your cookbook repository and
# put the overrides in YOUR customize.rb file.
###

# The following shows how to override the deploy user and shell:
#
#normal[:opsworks][:deploy_user][:shell] = '/bin/zsh'
#normal[:opsworks][:deploy_user][:user] = 'deploy'

migrate_node = 'worker1'

current_hostname = node[:opsworks][:instance][:hostname]

node[:deploy].each do |application, deploy|
  if migrate_node == current_hostname
    normal[:deploy][application][:migrate] = true
  else
    normal[:deploy][application][:migrate] = false
  end
end
