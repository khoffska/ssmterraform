data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

resource "aws_iam_instance_profile" "SNSNotificationsinstancerole2" {
  name = "${var.company_name}-SNSNotificationsinstancerole2"
  role = aws_iam_role.SNSNotificationsrole.name
}
resource "aws_iam_role" "SNSNotificationsrole" {
  name = "${var.company_name}-SNSNotificationsrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

EOF
}

resource "aws_iam_policy" "SNSPublishPermissions2" {
  name        = "${var.company_name}-SNSPublishPermissions"
  description = "SNSPublishPermissions2"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "SNSPublishPermissions2-attach" {
  role       = aws_iam_role.SNSNotificationsrole.name
  policy_arn = aws_iam_policy.SNSPublishPermissions2.arn
}




#SNSMAINTROLE

resource "aws_iam_role" "maintrole" {
  name = "${var.company_name}-maintrole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "sns.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#WIPchangeresourceinpolicy
resource "aws_iam_policy" "IAMpassrolesns5" {
  name        = "${var.company_name}-IAMpassrolesns5"
  description = "A test policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SNSNotifications"
        }
    ]
}

EOF
}

resource "aws_iam_role_policy_attachment" "passrolesns-attach" {
  role       = aws_iam_role.maintrole.name
  policy_arn = aws_iam_policy.IAMpassrolesns5.arn
}
resource "aws_iam_role_policy_attachment" "SSMmaint-attach" {
  role       = "${aws_iam_role.maintrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}


#SNS topic
resource "aws_sns_topic" "PRD-Instances" {
  name = "${var.company_name}-PRD-Instances"
}

resource "aws_sns_topic_subscription" "PRD-Instances-sub" {
  topic_arn = aws_sns_topic.PRD-Instances.arn
  protocol  = "email"
  endpoint  = "discwat@gmail.com"
}


#s3 create bucket
resource "random_string" "random" {
  length           = 5
  special          = false
}
resource "aws_s3_bucket" "patchinstaller" {
  bucket = "${var.company_name}-patchinstaller"

  tags = {
    Name        = "patchinstaller-${var.company_name}"
    Environment = "PRD"
  }
}

resource "aws_ssm_maintenance_window" "window" {
  name     = "maintenance-window-webapp"
  schedule = "${var.schedule}"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "target1" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "maintenance-window-target"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Environment"
    values = ["Production"]
  }
}
#Example of tagging
resource "aws_ec2_tag" "example" {
  resource_id = var.instance_id
  key         = "Environment"
  value       = "Production"
}
