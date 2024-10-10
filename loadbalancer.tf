#Create Application load balancer 
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  internal           = false
  ip_address_type    = "ipv4"
  subnets            = aws_subnet.public_subnet_web_tier[*].id
}

#Create application load balancer target group
resource "aws_lb_target_group" "app_lb_target_group" {
  name        = "app-lb-target-group"
  port        = 8443
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "instance"
  health_check {
    matcher             = "200"
    path                = "/"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 120
  }
}

#Create application load balancer listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_target_group.arn

  }
}
