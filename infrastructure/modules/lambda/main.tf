resource "aws_lambda_function" "ses_lambda" {
  filename         = "../../modules/lambda/index.zip"
  function_name    = "ses_lambda"
  role             = aws_iam_role.iam_lambda.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../../modules/lambda/index.zip")
  runtime          = "nodejs12.x"
}

resource "aws_iam_role" "iam_lambda" {
  name = "iam_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "ses_lambda_logging" {
  name              = "/aws/lambda/s3-static-site"
  retention_in_days = 14
}

resource "aws_iam_policy" "ses_lambda_logging" {
  name        = "ses_lambda_logging"
  path        = "/"
  description = "IAM policy for s3 static site lambda."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.ses_lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSESFullAccess" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}