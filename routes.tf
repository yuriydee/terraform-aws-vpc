################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id           = "${aws_vpc.my_vpc.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]

  tags = "${merge(var.tags, var.public_route_table_tags, map("Name", format("%s-public", var.vpc_name)))}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = "${max(length(var.private_subnets), length(var.elasticache_subnets), length(var.database_subnets))}"

  vpc_id           = "${aws_vpc.my_vpc.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]

  tags = "${merge(var.tags, var.public_route_table_tags, map("Name", format("%s-private", var.vpc_name)))}"

 lifecycle {
   ignore_changes = ["propagating_vgws"]
   # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
   # resources that manipulate the attributes of the routing table (typically for the private subnets)
 }
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
resource "aws_route_table_association" "database" {
  count = "${length(var.database_subnets)}"

  subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
resource "aws_route_table_association" "elasticache" {
  count = "${length(var.elasticache_subnets)}"

  subnet_id      = "${element(aws_subnet.elasticache.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
