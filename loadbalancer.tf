# Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  internal           = false
  ip_address_type    = "ipv4"
  subnets            = aws_subnet.public_subnet_web_tier[*].id
}

# Create Application Load Balancer Target Group
resource "aws_lb_target_group" "app_lb_target_group" {
  name     = "app-lb-target-group"
  port     = 8443
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

  health_check {
    matcher             = "200"
    path                = "/health" # Ensure this path returns 200
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 120
  }
}

# Create Application Load Balancer Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  }
}

# Register EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "web1_attachment" {
  target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  target_id        = aws_instance.ec2_web1_tier_1.id
  port             = 8443
}

resource "aws_lb_target_group_attachment" "web2_attachment" {
  target_group_arn = aws_lb_target_group.app_lb_target_group.arn
  target_id        = aws_instance.ec2_web2_tier_1.id
  port             = 8443
}
