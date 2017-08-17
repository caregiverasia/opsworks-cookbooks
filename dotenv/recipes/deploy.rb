require 'shellwords'
require 'fileutils'
node[:deploy].each do |application, deploy|
  rails_env = deploy[:rails_env]

  Chef::Log.info("Generating dotenv for app: #{application} with env: #{rails_env}... in #{deploy[:deploy_to]}")
  environment_variables = deploy[:app_env].to_h.merge(deploy[:environment_variables].to_h)
  
  begin
    FileUtils::mkdir_p "#{deploy[:deploy_to]}/shared"
    require 'yaml'

    environment_variables = deploy[:app_env].to_h.merge(deploy[:environment_variables].to_h)

    env_file_content = environment_variables.map{|name,value| "#{name}=#{value.to_s.shellescape}"}.join("\n")

    file "#{deploy[:deploy_to]}/shared/.env" do
      content env_file_content
      owner "deploy"
      group  "nginx"
      mode 00774
    end

  rescue SystemCallError
    Chef::Log.info("Failed.")
  end
end
