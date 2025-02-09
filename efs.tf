resource "aws_efs_file_system" "test" {
  creation_token = "my-efs-test"
  tags = {
    Name = "TEST"
  }
}

resource "aws_efs_mount_target" "test" {
  file_system_id  = aws_efs_file_system.test.id
  subnet_id       = data.aws_subnet.subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "test_ap" {
  file_system_id = aws_efs_file_system.test.id

  posix_user {
    uid = 1001
    gid = 1001
  }

  root_directory {
    path = "/app"
    creation_info {
      owner_uid   = 1001
      owner_gid   = 1001
      permissions = "755"
    }
  }
}

resource "aws_efs_file_system_policy" "ec2_access" {
  file_system_id = aws_efs_file_system.test.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.test.arn
        Condition = {
          StringEquals = {
            "aws:PrincipalArn"                 = aws_iam_role.ec2_role.arn
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.test_ap.arn
          }
        }
      }
    ]
  })
}

resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Allow inbound NFS traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs_sg"
  }
}