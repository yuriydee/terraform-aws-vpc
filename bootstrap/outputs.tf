#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "bootstrap_account_name" {
  value = "${var.bootstrap_account_name}"
}
output "bootstrap_bucket" {
  value = "${aws_s3_bucket.state_file_bucket.id}"
}
output "bootstrap_bucket_arn" {
  value = "${aws_s3_bucket.state_file_bucket.arn}"
}
