variable "aws_profile_name" {
  type        = string
  description = "The named AWS CLI profile to use"
}

variable "aws_region" {
  type        = string
  description = "The AWS region. Should match up with the region defined in the named CLI profile supplied in 'aws_profile_name'"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID. Should match up with the account ID defined in the named CLI profile supplied in 'aws_profile_name'"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "google_client_id" {
  type        = string
  description = "A Google OAuth Client ID, used for authentication with Cognito."
}

variable "google_client_secret" {
  type        = string
  description = "A Google OAuth Client ID, used for authentication with Cognito."
}

variable "common_tags" {
  description = "Common tags to be applied to all components."
}