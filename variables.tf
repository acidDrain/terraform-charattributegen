variable "github_repo_path" {
  type        = string
  description = "The GitHub repository that will use Actions to deploy to AWS S3/Cloudfront."
}

variable "environment" {
  type        = string
  description = "The target environment for deployment"
  default     = "production"
}

variable "region" {
  type        = string
  description = "The region in AWS for the deployment"
  default     = "us-west-2"
}
