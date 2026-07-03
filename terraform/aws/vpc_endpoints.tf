resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_app.id,
    aws_route_table.private_db.id
  ]

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-vpce-s3"
  })
}