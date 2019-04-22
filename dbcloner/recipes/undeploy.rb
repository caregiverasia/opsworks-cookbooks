node[:deploy].each do |application, deploy|
  Chef::Log.info("Removing database named: #{application}.")
  env = deploy[:app_env].to_h.merge(deploy[:environment_variables].to_h)

  begin
    script "delete db" do
      interpreter "bash"
      code <<-EOH
    mysqladmin -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST drop $DATABASE_NAME
    EOH
      environment env
      only_if do
        # Run only on worker nodes
        env['DATABASE_NAME'] != 'caregiverasia' && env['DATABASE_NAME'] != node[:dbcloner][:source] && env['RAILS_ENV'] != 'production' && node[:opsworks][:instance][:layers].include?('worker')
      end
      ignore_failure false
    end

  rescue SystemCallError
    Chef::Log.info("Failed.")
  end
end
