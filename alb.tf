provider "aws" {
  region = "us-east-1" # Update with your region
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0" # Verify latest version

  name               = "my-alb"
  load_balancer_type = "application"
  vpc_id             = "vpc-12345678"        # Replace with your VPC ID
  subnets            = ["subnet-1a2b3c4d", "subnet-5e6f7g8h"] # Public subnets
  security_groups    = ["sg-12345678"]       # ALB security group

  # HTTP listener (port 80)
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      # Default action (catch-all rule)
      default_action = {
        type             = "forward"
        target_group_arn = module.alb.target_groups["tg1"].arn
      }
    }
  }

  # Target Groups
  target_groups = {
    # First target group
    tg1 = {
      name_prefix      = "tg1-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path    = "/health"
        port    = "traffic-port"
        matcher = "200-299"
      }
    },
    # Second target group
    tg2 = {
      name_prefix      = "tg2-"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      health_check = {
        path    = "/status"
        port    = "traffic-port"
        matcher = "200-299"
      }
    }
  }

  # Listener Rules (11 rules)
  listener_rules = {
    # Rule 1-10: Custom rules
    rule1 = {
      listener_arn = module.alb.listeners["http"].arn
      priority     = 1
      conditions = [{
        path_pattern = {
          values = ["/api/*"]
        }
      }]
      actions = [{
        type             = "forward"
        target_group_arn = module.alb.target_groups["tg1"].arn
      }]
    }

    rule2 = {
      listener_arn = module.alb.listeners["http"].arn
      priority     = 2
      conditions = [{
        host_header = {
          values = ["app.example.com"]
        }
      }]
      actions = [{
        type             = "forward"
        target_group_arn = module.alb.target_groups["tg2"].arn
      }]
    }

    # Add rules 3-11 here following the same pattern
    # Example additional rule:
    rule3 = {
      listener_arn = module.alb.listeners["http"].arn
      priority     = 3
      conditions = [{
        http_header = {
          http_header_name = "X-Custom-Header"
          values           = ["my-header-value"]
        }
      }]
      actions = [{
        type             = "forward"
        target_group_arn = module.alb.target_groups["tg1"].arn
      }]
    }

    # Continue adding rules 4-11 with unique priorities...
  }
}

# Output ALB DNS name
output "alb_dns_name" {
  value = module.alb.lb_dns_name
}
