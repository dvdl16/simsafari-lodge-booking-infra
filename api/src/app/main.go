package main

import (
	"github.com/aws/aws-lambda-go/lambda"
)

type booking struct {
	BookingId    string   `json:"bookingId"`
	UserId       string   `json:"userId"`
	FromDate     int      `json:"fromDate"`
	ToDate       int      `json:"toDate"`
	Houses       []string `json:"houses` // Type SS (String Set) in DynamoDB
	GuestDetails string   `json:"guestDetails"`
}

func show() (*booking, error) {
	// Fetch a specific book record from the DynamoDB database. We'll
	// make this more dynamic in the next section.
	bk, err := getItem("e0a71c6a-0f12-4290-9eb1-c00060cf7d65")
	if err != nil {
		return nil, err
	}

	return bk, nil
}

func main() {
	lambda.Start(show)
}
