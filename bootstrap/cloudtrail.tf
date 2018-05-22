#--------------------------------------------------------------
# CloudTrail Logging
#--------------------------------------------------------------
resource "aws_cloudtrail" "cloudtrail_logging" {
  depends_on = ["aws_s3_bucket.cloudtrail_bucket"]
  name                          = "terraform-${var.bootstrap_account_name}-${var.bootstrap_region}-cloudtrail"
  s3_bucket_name                = "${aws_s3_bucket.cloudtrail_bucket.id}"
  s3_key_prefix                 = "${var.bootstrap_account_name}"
  is_multi_region_trail         = "${var.bootstrap_cloudtrail_multiregion}"
  include_global_service_events = true
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "terraform-${var.bootstrap_account_name}-${var.bootstrap_region}-cloudtrail"
  acl    = "private"
  # policy = "${aws_s3_bucket_policy.cloudtrail_bucket.policy}"
  tags   = "${var.bootstrap_tags}"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket" {
  bucket = "${aws_s3_bucket.cloudtrail_bucket.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
