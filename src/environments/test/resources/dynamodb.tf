resource "aws_dynamodb_table" "messages_table" {
  name           = "Messages"
  billing_mode   = "PAY_PER_REQUEST"
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