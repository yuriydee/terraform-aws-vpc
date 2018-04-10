###################
# Internet Gateway
###################
resource "aws_internet_gateway" "internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

##############
# NAT Gateway
##############
# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${(var.enable_nat_gateway && !var.reuse_nat_ips) ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(var.tags, map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))))}"

  depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.enable_nat_gateway ? length(var.private_subnets) : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
}

##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "vpn_gateway" {
  count = "${var.enable_vpn_gateway ? 1 : 0}"

  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}
