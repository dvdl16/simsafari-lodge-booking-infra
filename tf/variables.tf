variable "aws_region" {
  type        = string
  description = "The AWS region."
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID."
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

variable "project_name" {
  description = "Name of this Project, will be used in common tags."
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

variable "telegram_bot_token" {
  type        = string
  description = "Telegram Bot Token for Login Notification messages"
}

variable "telegram_chat_id" {
  type        = string
  description = "Telegram Chat ID for Login Notification messages"
}

variable "mx_record_value" {
  type        = string
  description = "An MX Record value."
}

variable "a_record_mail_value" {
  type        = string
  description = "Value for the mail A record."
}

variable "dkim_record_value" {
  type        = string
  description = "Value for the mail DKIM record."
}

variable "spf_record_value" {
  type        = string
  description = "Value for the mail SPF record."
}

variable "status_a_record_value" {
  type        = string
  description = "Value for the status.x.x A record."
}
