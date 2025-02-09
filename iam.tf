resource "aws_iam_role" "ec2_role" {
  name = "ec2-efs-secure-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-west-1"
        }
      }
    }
  ]
}
EOF
}

### EFS Secure Policy EC2 Access

resource "aws_iam_policy" "efs_access_policy" {
  name        = "EFSAccessPolicy"
  description = "Policy to allow ClientMount and ClientWrite for the EFS access point"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_access_point.test_ap.arn
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = aws_iam_role.ec2_role.arn
          }
        }
      }
    ]
  })
}

#### Attachments

resource "aws_iam_role_policy_attachment" "efs_secure_policy_attachment" {
  policy_arn = aws_iam_policy.efs_access_policy.arn
  role       = aws_iam_role.ec2_role.name
}

### EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-efs-secure-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}