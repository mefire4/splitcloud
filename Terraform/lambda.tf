# Compresse le code Python en zip, automatiquement
data "archive_file" "creer_groupe_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/creer_groupe.py"
  output_path = "${path.module}/../lambdas/creer_groupe.zip"
}


resource "aws_lambda_function" "creer_groupe" {
  function_name    = "creer-groupe"
  runtime          = "python3.13"
  handler          = "creer_groupe.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.creer_groupe_zip.output_path
  source_code_hash = data.archive_file.creer_groupe_zip.output_base64sha256
}


 
data "archive_file" "ajouter_depense_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/ajouter_depense.py"
  output_path = "${path.module}/../lambdas/ajouter_depense.zip"
}

resource "aws_lambda_function" "ajouter_depense" {
  function_name    = "ajouter-depense"
  runtime          = "python3.13"
  handler          = "ajouter_depense.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.ajouter_depense_zip.output_path
  source_code_hash = data.archive_file.ajouter_depense_zip.output_base64sha256
}

data "archive_file" "lister_depenses_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/lister_depenses.py"
  output_path = "${path.module}/../lambdas/lister_depenses.zip"
}

resource "aws_lambda_function" "lister_depenses" {
  function_name    = "lister-depenses"
  runtime          = "python3.13"
  handler          = "lister_depenses.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lister_depenses_zip.output_path
  source_code_hash = data.archive_file.lister_depenses_zip.output_base64sha256
}

data "archive_file" "calculer_soldes_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/calculer_soldes.py"
  output_path = "${path.module}/../lambdas/calculer_soldes.zip"
}

resource "aws_lambda_function" "calculer_soldes" {
  function_name    = "calculer-soldes"
  runtime          = "python3.13"
  handler          = "calculer_soldes.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.calculer_soldes_zip.output_path
  source_code_hash = data.archive_file.calculer_soldes_zip.output_base64sha256
}