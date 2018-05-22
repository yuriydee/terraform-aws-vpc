######
# VPC
######
resource "aws_vpc" "my_vpc" {
  cidr_block           = "${var.cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags = "${merge(var.tags, var.vpc_tags, map("Name", format("%s", var.vpc_name)))}"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "vpc_dns" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = "${var.dhcp_options_domain_name_servers}"
  ntp_servers          = "${var.dhcp_options_ntp_servers}"
  netbios_name_servers = "${var.dhcp_options_netbios_name_servers}"
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(var.tags, var.dhcp_options_tags, map("Name", format("%s", var.vpc_name)))}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "vpc_dns_opts" {
  count = "${var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${aws_vpc.my_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dns.id}"
}

###############################
# VPC Flow Logs
###############################
resource "aws_flow_log" "vpc_flow_log" {
  log_group_name = "${aws_cloudwatch_log_group.vpc_log_group.name}"
  iam_role_arn   = "${aws_iam_role.log_role.arn}"
  vpc_id         = "${aws_vpc.my_vpc.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "vpc_log_group" {
  name = "vpc_log_group"
}

resource "aws_iam_role" "log_role" {
  name = "log_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "log_policy" {
  name = "log_policy"
  role = "${aws_iam_role.log_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
