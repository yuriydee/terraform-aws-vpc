#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "bootstrap_account_name" {}
variable "bootstrap_region" {}
variable "bootstrap_cloudtrail_multiregion" {
  default = false
}
variable "bootstrap_tags" {
  type = "map"
}
variable "generate_ssh_key" {}
variable "ssh_key_algorithm" {
  default = "RSA"
}
variable "key_pair_name" {}
variable "state_lock_read_capacity" {
  default = "1"
}
variable "state_lock_write_capacity" {
  default = "1"
}
