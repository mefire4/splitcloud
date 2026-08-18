resource "aws_dynamodb_table" "groupes" {
  name         = "Groupes"
  billing_mode = "PAY_PER_REQUEST"  # équivalent du mode "On-Demand" qu'on a choisi dans la console
  hash_key     = "groupe_id"

  attribute {
    name = "groupe_id"
    type = "S"  # S = String
  }
}

resource "aws_dynamodb_table" "depenses" {
  name         = "depenses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "groupe_id"
  range_key    = "depense-SortKey"

  attribute {
    name = "groupe_id"
    type = "S"
  }

  attribute {
    name = "depense-SortKey"
    type = "S"
  }
}