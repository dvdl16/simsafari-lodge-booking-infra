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

variable "payfast_confirmation_address" {
  type        = string
  description = "The email address to send the confirmation email to"
}

variable "payfast_email_confirmation" {
  type        = string
  description = "Whether to send an email confirmation to the merchant of the transaction. The email confirmation is automatically sent to the payer. 1 = on, 0 = off"
}

variable "payfast_merchant_id" {
  type        = string
  description = "The Merchant ID as given by the PayFast system. Used to uniquely identify the receiving account. This can be found on the merchant’s settings page."
}

variable "payfast_merchant_key" {
  type        = string
  description = "The Merchant Key as given by the PayFast system. Used to uniquely identify the receiving account"
}

variable "payfast_onsite_url" {
  type        = string
  description = "URL for Payfast Onsite Payments (Beta)"
}

variable "payfast_passphrase" {
  type        = string
  description = "Passphrase for Payfast account"
}
