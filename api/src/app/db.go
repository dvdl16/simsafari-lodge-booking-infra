package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/expression"
)

// Example CLI command to insert new records
// aws dynamodb put-item --table-name tf-bookings-table --item '{"bookingId": {"S": "e0a71c6a-0f12-4290-9eb1-c00060cf7d65"}, "guestDetails": {"S": "Birthday weekend"}, "houses":  {"SS": ["Laarse", "Rondavel"]}}' --profile=jabulani

// Declare a new DynamoDB instance. Note that this is safe for concurrent use.
var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion("eu-west-1"))

func getBookings(minFromDate string) (*[]booking, error) {
	// Prepare the input for the query.
	filt := expression.Name("fromDate").GreaterThan(expression.Value(minFromDate))
	proj := expression.NamesList(
		expression.Name("bookingId"),
		expression.Name("userId"),
		expression.Name("fromDate"),
		expression.Name("toDate"),
		expression.Name("houses"),
		expression.Name("guestDetails"),
	)
	expr, err := expression.NewBuilder().WithFilter(filt).WithProjection(proj).Build()

	if err != nil {
		errorLogger.Printf("Got error building expression: %s", err)
		return nil, err
	}

	// Build the query input parameters
	params := &dynamodb.ScanInput{
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		FilterExpression:          expr.Filter(),
		ProjectionExpression:      expr.Projection(),
		TableName:                 aws.String("tf-bookings-table"),
	}

	// Make the DynamoDB Query API call
	result, err := db.Scan(params)
	if err != nil {
		errorLogger.Printf("Query API call failed: %s", err)
		return nil, err
	}

	// Handle the result
	bookings := new([]booking)
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, bookings)
	if err != nil {
		return nil, err
	}
	return bookings, nil
}

// Add a booking record to DynamoDB.
func putBooking(bk *booking) error {
	var houses []*string
	for _, i := range bk.Houses {
		houses = append(houses, aws.String(i))
	}

	input := &dynamodb.PutItemInput{
		TableName: aws.String("tf-bookings-table"),
		Item: map[string]*dynamodb.AttributeValue{
			"bookingId": {
				S: aws.String(bk.BookingId),
			},
			"userId": {
				S: aws.String(bk.UserId),
			},
			"fromDate": {
				S: aws.String(bk.FromDate),
			},
			"toDate": {
				S: aws.String(bk.ToDate),
			},
			"houses": {
				SS: houses,
			},
			"guestDetails": {
				S: aws.String(bk.GuestDetails),
			},
		},
	}

	_, err := db.PutItem(input)
	return err
}

// Update a booking record in DynamoDB.
func updateBooking(bk *booking) error {
	var houses []*string
	for _, i := range bk.Houses {
		houses = append(houses, aws.String(i))
	}
	input := &dynamodb.UpdateItemInput{
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":userId": {
				S: aws.String(bk.UserId),
			},
			":fromDate": {
				S: aws.String(bk.FromDate),
			},
			":toDate": {
				S: aws.String(bk.ToDate),
			},
			":houses": {
				SS: houses,
			},
			":guestDetails": {
				S: aws.String(bk.GuestDetails),
			},
		},
		TableName: aws.String("tf-bookings-table"),
		Key: map[string]*dynamodb.AttributeValue{
			"bookingId": {
				S: aws.String(bk.BookingId),
			},
		},
		ReturnValues:     aws.String("UPDATED_NEW"),
		UpdateExpression: aws.String("set userId = :userId, fromDate = :fromDate, toDate = :toDate, houses = :houses, guestDetails = :guestDetails"),
	}

	_, err := db.UpdateItem(input)
	return err
}

func getUsers() (*[]user, error) {
	// Prepare the input for the query.
	proj := expression.NamesList(
		expression.Name("userId"),
		expression.Name("name"),
		expression.Name("phone"),
		expression.Name("email"),
		expression.Name("lastLoggedIn"),
		expression.Name("otp"),
		expression.Name("thirdParty"),
	)
	expr, err := expression.NewBuilder().WithProjection(proj).Build()
	if err != nil {
		errorLogger.Printf("Got error building expression: %s", err)
		return nil, err
	}

	// Build the query input parameters
	params := &dynamodb.ScanInput{
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		FilterExpression:          expr.Filter(),
		ProjectionExpression:      expr.Projection(),
		TableName:                 aws.String("tf-users-table"),
	}

	// Make the DynamoDB Query API call
	result, err := db.Scan(params)
	if err != nil {
		errorLogger.Printf("Query API call failed: %s", err)
		return nil, err
	}

	// Handle the result
	users := new([]user)
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, users)
	if err != nil {
		return nil, err
	}
	return users, nil
}

// Add a user record to DynamoDB.
func putUser(usr *user) error {
	input := &dynamodb.PutItemInput{
		TableName: aws.String("tf-users-table"),
		Item: map[string]*dynamodb.AttributeValue{
			"userId": {
				S: aws.String(usr.UserId),
			},
			"name": {
				S: aws.String(usr.Name),
			},
			"phone": {
				S: aws.String(usr.Phone),
			},
			"email": {
				S: aws.String(usr.Email),
			},
			"lastLoggedIn": {
				S: aws.String(usr.LastLoggedIn),
			},
			"otp": {
				S: aws.String(usr.OTP),
			},
			"thirdParty": {
				S: aws.String(usr.ThirdParty),
			},
		},
	}

	_, err := db.PutItem(input)
	return err
}

// Update a user record in DynamoDB.
func updateUser(usr *user) error {
	input := &dynamodb.UpdateItemInput{
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":n": {
				S: aws.String(usr.Name),
			},
			":phone": {
				S: aws.String(usr.Phone),
			},
			":email": {
				S: aws.String(usr.Email),
			},
			":lastLoggedIn": {
				S: aws.String(usr.LastLoggedIn),
			},
			":otp": {
				S: aws.String(usr.OTP),
			},
			":thirdParty": {
				S: aws.String(usr.ThirdParty),
			},
		},
		ExpressionAttributeNames: map[string]*string{
			"#username": aws.String("name"),
		},
		TableName: aws.String("tf-users-table"),
		Key: map[string]*dynamodb.AttributeValue{
			"userId": {
				S: aws.String(usr.UserId),
			},
		},
		ReturnValues:     aws.String("UPDATED_NEW"),
		UpdateExpression: aws.String("set #username = :n, phone = :phone, email = :email, lastLoggedIn = :lastLoggedIn, otp = :otp, thirdParty = :thirdParty"),
	}

	_, err := db.UpdateItem(input)
	return err
}
