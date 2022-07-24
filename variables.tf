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
