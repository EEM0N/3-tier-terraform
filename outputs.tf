# Output for public IPs
output "web_tier_public_ips" {
  value = [
    aws_instance.ec2_web1_tier_1.public_ip,
    aws_instance.ec2_web2_tier_1.public_ip,
  ]
}

output "app_tier_private_ips" {
  value = [
    aws_instance.ec2_app1_tier_2.private_ip,
    aws_instance.ec2_app2_tier_2.private_ip,
  ]
}