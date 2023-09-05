
resource "aws_security_group" "my-sg" {
    name = "${var.name}-sg"
    description = "THis security group is for SSH and HTTP"
    vpc_id = aws_vpc.my-vpc.id
    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
       # ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        description      = "HTTP"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
       # ipv6_cidr_blocks = ["::/0"]
    }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_launch_template" "my-lt" {
    name = "${var.name}-lt"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    #subnet_id = var.public_subnet_a_cidr   
    key_name = var.key_name
    image_id = var.image_id  
    user_data = base64encode(<<EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        echo "Hello world" > /var/www/html/index.html
        systemctl start httpd
        systemctl enable httpd

    EOF
    )
    tags = {
        Name = "${var.name}-lt1"
        Env = "ops"
    }

}

resource "aws_autoscaling_group" "asg" {
    name = "${var.name}-asg"
    max_size = 3
    min_size =  1
    desired_capacity =  2
    # availability_zones = [var.az1, var.az2]
    vpc_zone_identifier = [aws_subnet.private-subnet-a.id , aws_subnet.private-subnet-b.id]
    
    launch_template {
      id = aws_launch_template.my-lt.id
      version = "$Latest"               
    }
}
resource "aws_autoscaling_policy" "my-asp"{
  name                   = "${var.name}-scp"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "metric" {
  alarm_name          = "${var.name}-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 50

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.my-asp.arn]
}



resource "aws_lb_target_group" "my-tg" {
  name = "${var.name}-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my-vpc.id 
  tags = {
    Name = "${var.name}-tg"
    Env = "ops"
  }
}



resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.my-tg.arn
}

resource "aws_lb" "my-lb" {
  name = "${var.name}-lb"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.my-sg.id]
  subnets = [aws_subnet.public-subnet-a.id , aws_subnet.public-subnet-b.id]
  tags = {
    Name = "${var.name}-lb"
    Env = "ops"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my-lb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-tg.arn
  }
}

