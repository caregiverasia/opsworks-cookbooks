chef_gem "aws-sdk-core" do
  version "~> 2.6"
  action :install
end

ruby_block "attach to ALB" do
  block do
    require "aws-sdk-core"
    Aws.use_bundled_cert!

    raise "alb_helper block not specified in layer JSON" if node[:alb_helper].nil?
    raise "Target group ARN not specified in layer JSON" if node[:alb_helper][:target_group_arn].nil?

    instance_region = node["opsworks"]["instance"]["region"]
    ec2_instance_id = node["opsworks"]["instance"]["aws_instance_id"]
    target_group_arn = node[:alb_helper][:target_group_arn]

    Chef::Log.info("Creating ELB client in region #{instance_region}")
    client = Aws::ElasticLoadBalancingV2::Client.new(region: instance_region)

    Chef::Log.info("Registering EC2 instance #{ec2_instance_id} with target group #{target_group_arn}")

    target_to_attach = {
      target_group_arn: target_group_arn,
      targets: [{ id: ec2_instance_id }]
    }

    client.register_targets(target_to_attach)
  end
  action :run
end
