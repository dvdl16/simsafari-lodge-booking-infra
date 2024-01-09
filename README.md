# SimSafari Lodge Booking Infrastructure

This repository contains source code for managing the infrastructure and backend API for the [SimSafari Lodge Booking app](https://github.com/dvdl16/simsafari-lodge-booking).

### Architecture
- Terraform is used to manage the infrastructure on AWS
- The backend a serverless API with Go and AWS Lambda

### Deploying the infrastructure
Make sure to have a `.tfvars` file or to supply the following terraform variables:
```bash
aws_region       = "eu-west-1"
aws_account_id   = "1234567"

domain_name = "example.com"
bucket_name = "example.com"

google_client_id      = "12345abcd.apps.googleusercontent.com"
google_client_secret  = "ABCDEFG"

payfast_merchant_id          = "10004002"
payfast_merchant_key         = "q1cd2rdny4a53"
payfast_onsite_url           = "https://sandbox.payfast.co.za/onsite/process"
payfast_passphrase           = "payfast"
payfast_confirmation_address = "webmaster@example.com"
payfast_email_confirmation   = "1"

project_name = "my-project"

```

> Make sure that `payments.zip` exists in the root directory (see [this repo](https://github.com/dvdl16/simsafari-lodge-booking-payment-lambda))


To deploying the infrastructure, use the following terraform commands:
```bash
cd tf

# Only required for the first-time run
AWS_PROFILE=jabulani terraform init

# Run to deploy from your workstation
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx 
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Building the Go backend locally

These are the commands to build, run from `simsafari-lodge-booking-infra/api`:

```bash
env GOOS=linux GOARCH=amd64 go build -o ./main  src/app/*.go
```

> Important: as part of this command we're using env to temporarily set two environment variables for the duration for the command (GOOS=linux and GOARCH=amd64). These instruct the Go compiler to create an executable suitable for use with a linux OS and amd64 architecture — which is what it will be running on when we deploy it to AWS

AWS requires lambda functions in a zip file, so make a `main.zip` zip file containing the built executable.
```bash
zip -j main.zip main
```

To manually deploy the latest version to Lambda:
```bash
aws lambda update-function-code --function-name SimSafari_Lodge_Booking_API --zip-file fileb://main.zip --profile jabulani
```

### Building the Login Notification lambda code locally
```bash
cd venv/lib/python3.9/site-packages/
zip -r ../../../../lambda_function.zip .
cd ../../../../
zip -g lambda_function.zip *.py
```

### Upgrading terraform or terraform providers
After modifying `providers.tf` and `deploy.yml`, run:

```shell
AWS_PROFILE=jabulani terraform init -upgrade
```

### Other Notes

`go mod tidy` was used. It ensures that the go.mod file matches the source code in the module. It adds any missing module requirements necessary to build the current module’s packages and dependencies, and it removes requirements on modules that don’t provide any relevant packages. It also adds any missing entries to go.sum and removes unnecessary entries (credit to [S.D.](https://stackoverflow.com/a/68001204))

### Pipeline Variables and Secrets

The following Github Actions Variables are used:
```shell
# Required for Terraform
AWS_REGION

# Payfast setup to accept payments
PAYFAST_ONSITE_URL

# Required to have working email
A_RECORD_MAIL_VALUE
MX_RECORD_VALUE
SPF_RECORD_MAIL_VALUE
SRV_RECORD_VALUE
```

The following Github Actions Secrets are used:

```shell
# Required for Terraform
AWS_ACCOUNT_ID                  # AWS Account ID
AWS_ACCESS_KEY_ID               # AWS Access Key ID
AWS_SECRET_ACCESS_KEY           # AWS Access Key Secret
BUCKET_NAME                     # S3 Bucket name for Static files hosting
DOMAIN_NAME                     # e.g. mysite.com
GOOGLE_CLIENT_ID                # Used for Cognito (SSO with Google)
GOOGLE_CLIENT_SECRET            # Used for Cognito (SSO with Google)
PROJECT                         # Used as a resource tag

# Login Notifications
TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID

# Dependabot monitoring
UPTIME_KUMA_URL

# Payfast setup to accept payments
PAYFAST_CONFIRMATION_ADDRESS
PAYFAST_EMAIL_CONFIRMATION
PAYFAST_MERCHANT_ID
PAYFAST_MERCHANT_KEY
PAYFAST_PASSPHRASE

# Required to have working email
DKIM_RECORD_VALUE           # Note that TXT records have a max of 255 characters
                            # It may be necessary to split the value up
                            # e.g. VERY-LONG-DKIM-STRING becomes VERY-LONG-D" "KIM-STRING
                            # Note the peculiar quotation marks (AWS Route53 automatically adds outer quotation marks)
```