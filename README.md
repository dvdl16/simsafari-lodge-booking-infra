# SimSafari Lodge Booking Infrastructure

This repository contains source code for managing the infrastructure and backend API for the [SimSafari Lodge Booking app](https://github.com/dvdl16/simsafari-lodge-booking).

### Architecture
- Terraform is used to manage the infrastructure on AWS
- The backend a serverless API with Go and AWS Lambda

### Deploying the infrastructure
Use the following terraform commands:
```bash
terraform plan
terraform apply
```

*Note that terraform expects a AWS CLI profile named `jabulani`.

### Building and running the Go backend locally

These are the commands to build, run from `simsafari-lodge-booking-infra/api`:

```bash
env GOOS=linux GOARCH=amd64 go build src/app/main.go
env GOOS=linux GOARCH=amd64 go build src/app/*.go

```

> Important: as part of this command we're using env to temporarily set two environment variables for the duration for the command (GOOS=linux and GOARCH=amd64). These instruct the Go compiler to create an executable suitable for use with a linux OS and amd64 architecture — which is what it will be running on when we deploy it to AWS

AWS requires lambda functions in a zip file, so make a `main.zip` zip file containing the built executable.
```bash
zip -j main.zip main
```