#--------------------------------------------------------------
# DynamoDB Lock Tables
#--------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_statelock_common" {
  name           = "${var.bootstrap_account_name}-${var.bootstrap_region}-common"
  read_capacity  = "${var.state_lock_read_capacity}"
  write_capacity = "${var.state_lock_write_capacity}"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = "${var.bootstrap_tags}"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.bootstrap_account_name}-${var.bootstrap_region}"
  read_capacity  = "${var.state_lock_read_capacity}"
  write_capacity = "${var.state_lock_write_capacity}"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = "${var.bootstrap_tags}"
}
