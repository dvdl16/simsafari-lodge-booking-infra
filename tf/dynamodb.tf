# Database table for bookings
resource "aws_dynamodb_table" "tf_bookings_table" {
  name           = "tf-bookings-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = "5"
  write_capacity = "5"
  attribute {
    name = "bookingId"
    type = "S"
  }
  hash_key = "bookingId"
}