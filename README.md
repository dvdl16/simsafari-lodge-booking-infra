# SimSafari Lodge Booking Infrastructure

This repository contains source code for managing the infrastructure and backend API for the [SimSafari Lodge Booking app](https://github.com/dvdl16/simsafari-lodge-booking).

### Architecture
- Terraform is used to manage the infrastructure on AWS
- The backend a serverless API with Go and AWS Lambda

### Deploying the infrastructure
Make sure to have a `.tfvars` file or to supply the following terraform variables:
```bash
aws_access_key = "ABCDEFG"
aws_secret_key = "ABCDEFG"
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

common_tags = {
  Project = "my-project"
}

```

> Make sure that `payments.zip` exists in the root directory (see [this repo](https://github.com/dvdl16/simsafari-lodge-booking-payment-lambda))


To deploying the infrastructure, use the following terraform commands:
```bash
cd tf

# Only required for the first-time run
AWS_PROFILE=jabulani terraform init

# Run to deploy from your workstation
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
cd venv/lib/python3.8/site-packages/
zip -r ../../../../lambda_function.zip .
cd ../../../../
zip -g lambda_function.zip *.py
```

### Other Notes

`go mod tidy` was used. It ensures that the go.mod file matches the source code in the module. It adds any missing module requirements necessary to build the current module’s packages and dependencies, and it removes requirements on modules that don’t provide any relevant packages. It also adds any missing entries to go.sum and removes unnecessary entries (credit to [S.D.](https://stackoverflow.com/a/68001204))
