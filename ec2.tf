resource "aws_instance" "efs_instance" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.ec2_efs.name}"]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y amazon-efs-utils
    sudo yum install -y amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
    mkdir -p /mnt/efs
    echo "${aws_efs_file_system.test.dns_name}:/ /mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
    sudo mount -a
  EOF

  tags = {
    Name = "EFS Instance"
  }
}

resource "aws_security_group" "ec2_efs" {
  name        = "ec2-efs-sg"
  description = "Security group for EC2 instance with EFS access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ec2_efs_sg"
  }
}
