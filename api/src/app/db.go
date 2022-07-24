package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

// Example CLI command to insert new records
// aws dynamodb put-item --table-name tf-bookings-table --item '{"bookingId": {"S": "e0a71c6a-0f12-4290-9eb1-c00060cf7d65"}, "guestDetails": {"S": "Birthday weekend"}, "houses":  {"SS": ["Laarse", "Rondavel"]}}' --profile=jabulani

// Declare a new DynamoDB instance. Note that this is safe for concurrent
// use.
var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion("eu-west-1"))

func getItem(bookingId string) (*booking, error) {
	// Prepare the input for the query.
	input := &dynamodb.GetItemInput{
		TableName: aws.String("tf-bookings-table"),
		Key: map[string]*dynamodb.AttributeValue{
			"bookingId": {
				S: aws.String(bookingId),
			},
		},
	}

	// Retrieve the item from DynamoDB. If no matching item is found
	// return nil.
	result, err := db.GetItem(input)
	if err != nil {
		return nil, err
	}
	if result.Item == nil {
		return nil, nil
	}

	// The result.Item object returned has the underlying type
	// map[string]*AttributeValue. We can use the UnmarshalMap helper
	// to parse this straight into the fields of a struct. Note:
	// UnmarshalListOfMaps also exists if you are working with multiple
	// items.
	bk := new(booking)
	err = dynamodbattribute.UnmarshalMap(result.Item, bk)
	if err != nil {
		return nil, err
	}

	return bk, nil
}

// Add a booking record to DynamoDB.
func putItem(bk *booking) error {
	input := &dynamodb.PutItemInput{
		TableName: aws.String("tf-bookings-table"),
		Item: map[string]*dynamodb.AttributeValue{
			"bookingId": {
				S: aws.String(bk.BookingId),
			},
			"userId": {
				S: aws.String(bk.UserId),
			},
			// "fromDate": {
			// 	N: aws.Int(bk.FromDate),
			// },
			// "toDate": {
			// 	N: aws.Int(bk.ToDate),
			// },
			// "houses": {
			//     SS: aws.StringSet(bk.Houses),
			// },
			"guestDetails": {
				S: aws.String(bk.GuestDetails),
			},
		},
	}

	_, err := db.PutItem(input)
	return err
}
