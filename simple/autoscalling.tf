resource "aws_autoscaling_group" "backendASG" {
  name = "backendASG"
  launch_template {
    id      = aws_launch_template.backendLT.id
    version = "$Latest"
  }

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.Privatesubnet1.id, aws_subnet.Privatesubnet2.id]
  target_group_arns         = [aws_lb_target_group.backendTG.arn]
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "BackendAutoScalingInstance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "backend_cpu" {
  name                    = "backend-cpu-scaling-policy"
  autoscaling_group_name  = aws_autoscaling_group.backendASG.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = 50.0
    disable_scale_in = false  
  }
}


resource "aws_autoscaling_group" "frontendASG" {
  name = "frontendASG"
  launch_template {
    id      = aws_launch_template.frontendLT.id
    version = "$Latest"
  }

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.Publicsubnet1.id, aws_subnet.Publicsubnet2.id]
  target_group_arns         = [aws_lb_target_group.frontendTG.arn]
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "FrontendAutoScalingInstance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "frontend_cpu" {
  name                    = "frontend-cpu-scaling-policy"
  autoscaling_group_name  = aws_autoscaling_group.frontendASG.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value     = 50.0
    disable_scale_in = false  
  }
}
