################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-public-%s", var.vpc_name, element(var.azs, count.index))))}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-private-%s", var.vpc_name, element(var.azs, count.index))))}"
}

##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = "${length(var.database_subnets)}"

  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.database_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.database_subnet_tags, map("Name", format("%s-db-%s", var.vpc_name, element(var.azs, count.index))))}"
}

resource "aws_db_subnet_group" "database" {
  count = "${length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0}"

  name        = "database-${var.vpc_name}"
  description = "Database subnet group for ${var.vpc_name}"
  subnet_ids  = ["${aws_subnet.database.*.id}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.vpc_name)))}"
}

#####################
# ElastiCache subnet
#####################
resource "aws_subnet" "elasticache" {
  count = "${length(var.elasticache_subnets)}"

  vpc_id            = "${aws_vpc.my_vpc.id}"
  cidr_block        = "${var.elasticache_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(var.tags, var.elasticache_subnet_tags, map("Name", format("%s-elasticache-%s", var.vpc_name, element(var.azs, count.index))))}"
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = "${length(var.elasticache_subnets) > 0 ? 1 : 0}"

  name        = "elasticache-${var.vpc_name}"
  description = "ElastiCache subnet group for ${var.vpc_name}"
  subnet_ids  = ["${aws_subnet.elasticache.*.id}"]
}
