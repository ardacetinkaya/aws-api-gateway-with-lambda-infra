resource "aws_dynamodb_table" "messages_table" {
  name           = "Messages"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "Id"
  range_key      = "Date"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "Date"
    type = "S"
  }

}