# Output for public IPs
output "web_tier_public_ips" {
  value = [
    aws_instance.ec2-web-tier-1.public_ip,
    aws_instance.ec2-web-tier-2.public_ip,
  ]
}

output "app_tier_private_ips" {
  value = [
    aws_instance.ec2-app-tier-1.private_ip,
    aws_instance.ec2-app-tier-2.private_ip,
  ]
}