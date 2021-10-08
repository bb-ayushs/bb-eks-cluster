
################################################################################
# S3 bucket
################################################################################
module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-${var.environment}-${var.project_name}"
  acl    = "public-read"

  versioning = {
    enabled = false
  }
  cors_rule = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      allowed_headers = ["Authorization",
                         "Content-Range",
                         "Accept",
                         "Content-Type",
                         "Origin",
                         "Range"]
      expose_headers  = ["Content-Range",
                         "Content-Length",
                         "ETag"]
      max_age_seconds = 3000
    }
  ]
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

