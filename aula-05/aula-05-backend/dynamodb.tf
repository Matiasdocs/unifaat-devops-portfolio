resource "aws_dynamodb_table" "locks" {
  name         = "technova-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "technova-terraform-locks"
  }
}
