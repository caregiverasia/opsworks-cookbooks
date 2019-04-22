node[:deploy].each do |application, deploy|
  Chef::Log.info("Cloning database named: #{application} from source: #{node[:dbcloner][:source]}.")
  env = deploy[:app_env].to_h.merge(deploy[:environment_variables].to_h)

  begin
    script "clone db" do
      cwd release_path
      interpreter "bash"
      code <<-EOH
    export LANG=C
    mysqladmin -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST create $DATABASE_NAME && \
    mysqldump --no-data -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST "cgastaging" | mysql -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST $DATABASE_NAME && \
    mysqldump --no-create-info --ignore-table="#{node[:dbcloner][:source]}"."versions" -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST "#{node[:dbcloner][:source]}" | mysql -u $DATABASE_USERNAME -p$DATABASE_PASSWORD -h $DATABASE_HOST $DATABASE_NAME
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
