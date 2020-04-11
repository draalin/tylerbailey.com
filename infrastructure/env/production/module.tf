module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  domain_name  = var.domain_name
}

module "acm" {
  source       = "../../modules/acm"
  project_name = var.project_name
  domain_name  = var.domain_name
}

module "route53" {
  source                 = "../../modules/route53"
  project_name           = var.project_name
  domain_name            = var.domain_name
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront             = module.cloudfront.cloudfront
}

module "ses" {
  source      = "../../modules/ses"
  domain_name = var.domain_name
}

module "cloudfront" {
  source       = "../../modules/cloudfront"
  domain_name  = var.domain_name
  project_name = var.project_name
  compress     = var.compress
  certificate  = module.acm.certificate
  media        = module.s3.s3_bucket_domain_name
}

module "api" {
  source        = "../../modules/api"
  project_name  = var.project_name
  invoke_arn    = module.lambda.invoke_arn
  function_name = module.lambda.function_name
}

module "lambda" {
  source       = "../../modules/lambda"
  project_name = var.project_name
}