#--------------------------------------------------------------
# Infrastructure Buckets
#--------------------------------------------------------------
resource "aws_s3_bucket" "log_bucket" {
  bucket = "terraform-${var.bootstrap_account_name}-${var.bootstrap_region}-logging"
  acl    = "log-delivery-write"
  tags   = "${var.bootstrap_tags}"
}

resource "aws_s3_bucket" "state_file_bucket" {
  bucket = "terraform-${var.bootstrap_account_name}-${var.bootstrap_region}-state"
  acl    = "private"
  tags   = "${var.bootstrap_tags}"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "logs/"
  }
}
