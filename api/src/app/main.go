package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/google/uuid"
)

var errorLogger = log.New(os.Stderr, "ERROR ", log.Llongfile)
var debugLogger = log.New(os.Stderr, "DEBUG ", log.Llongfile)

type booking struct {
	Id           string   `json:"id"`
	UserId       string   `json:"userId"`
	FromDate     string   `json:"fromDate"`
	ToDate       string   `json:"toDate"`
	Houses       []string `json:"houses` // Type SS (String Set) in DynamoDB
	GuestDetails string   `json:"guestDetails"`
	UserContact  string   `json:"userContact"`
	UserName     string   `json:"userName"`
}

// Do a switch on the HTTP request method to determine which action to take.
func router(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "OPTIONS":
		return options(req)
	case "GET":
		return show(req)
	case "POST":
		return create(req)
	case "PUT":
		return update(req)
	case "DELETE":
		return deleteResource(req)
	default:
		return clientError(http.StatusMethodNotAllowed, "Only GET and POST allowed")
	}
}

func options(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// Return a response with a 200 OK status and the required CORS headers
	return events.APIGatewayProxyResponse{
		Headers: map[string]string{
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET,POST,PUT,DELETE,OPTIONS",
			"Access-Control-Allow-Headers":     "X-Amz-Date,X-Api-Key,X-Amz-Security-Token,X-Requested-With,X-Auth-Token,Referer,User-Agent,Origin,Content-Type,Authorization,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers",
			"Access-Control-Allow-Credentials": "'true'",
		},
		StatusCode: http.StatusOK,
		Body:       string("Hello world"),
	}, nil

}

func show(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// Get the `fromDate` query string parameter from the request and
	// validate it.
	fromDate := req.QueryStringParameters["fromDate"]
	if fromDate == "" {
		return clientError(http.StatusBadRequest, "Expected a 'fromDate' parameter")
	}

	// Fetch the booking record from the database based on the fromDate value.
	bks, err := getBookings(fromDate)
	if err != nil {
		return serverError(err)
	}
	if bks == nil {
		return clientError(http.StatusNotFound, "Bookings not found")
	}

	// The APIGatewayProxyResponse.Body field needs to be a string, so
	// we marshal the booking record into JSON.
	js, err := json.Marshal(bks)
	if err != nil {
		return serverError(err)
	}

	// Return a response with a 200 OK status and the JSON booking record
	// as the body.
	return events.APIGatewayProxyResponse{
		Headers: map[string]string{
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET,POST,PUT,DELETE,OPTIONS",
			"Access-Control-Allow-Headers":     "X-Amz-Date,X-Api-Key,X-Amz-Security-Token,X-Requested-With,X-Auth-Token,Referer,User-Agent,Origin,Content-Type,Authorization,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers",
			"Access-Control-Allow-Credentials": "'true'",
		},
		StatusCode: http.StatusOK,
		Body:       string(js),
	}, nil

}

func create(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if req.Headers["content-type"] != "application/json" && req.Headers["Content-Type"] != "application/json" {
		return clientError(http.StatusNotAcceptable, "Malformed or incorrect headers")
	}

	bk := new(booking)
	err := json.Unmarshal([]byte(req.Body), bk)
	if err != nil {
		errorLogger.Println("Request has invalid format:")
		errorLogger.Println(err)
		return clientError(http.StatusUnprocessableEntity, "Invalid object format")
	}

	if !IsValidUUID(bk.Id) {
		return clientError(http.StatusBadRequest, "Invalid booking ID")
	}
	if bk.GuestDetails == "" {
		return clientError(http.StatusBadRequest, "Guest Details cannot be empty")
	}
	if bk.UserContact == "" {
		return clientError(http.StatusBadRequest, "User Contact cannot be empty")
	}
	if bk.UserName == "" {
		return clientError(http.StatusBadRequest, "User Name cannot be empty")
	}

	err = putBooking(bk)
	if err != nil {
		return serverError(err)
	}

	// The APIGatewayProxyResponse.Body field needs to be a string, so
	// we marshal the booking record into JSON.
	js, err := json.Marshal(bk)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 201,
		Headers: map[string]string{
			"Location":                         fmt.Sprintf("/bookings?id=%s", bk.Id),
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET,POST,PUT,DELETE,OPTIONS",
			"Access-Control-Allow-Headers":     "X-Amz-Date,X-Api-Key,X-Amz-Security-Token,X-Requested-With,X-Auth-Token,Referer,User-Agent,Origin,Content-Type,Authorization,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers",
			"Access-Control-Allow-Credentials": "'true'",
		},
		Body: string(js),
	}, nil

}

func update(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if req.Headers["content-type"] != "application/json" && req.Headers["Content-Type"] != "application/json" {
		return clientError(http.StatusNotAcceptable, "Malformed or incorrect headers")
	}

	bk := new(booking)
	err := json.Unmarshal([]byte(req.Body), bk)
	if err != nil {
		errorLogger.Println("Request has invalid format:")
		errorLogger.Println(err)
		return clientError(http.StatusUnprocessableEntity, "Invalid object format")
	}

	// Validation
	if bk.GuestDetails == "" {
		return clientError(http.StatusBadRequest, "Guest Details cannot be empty")
	}
	if bk.UserContact == "" {
		return clientError(http.StatusBadRequest, "User Contact cannot be empty")
	}
	if bk.UserName == "" {
		return clientError(http.StatusBadRequest, "User Name cannot be empty")
	}

	err = updateBooking(bk)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Location":                         fmt.Sprintf("/bookings?id=%s", bk.Id),
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET,POST,PUT,DELETE,OPTIONS",
			"Access-Control-Allow-Headers":     "X-Amz-Date,X-Api-Key,X-Amz-Security-Token,X-Requested-With,X-Auth-Token,Referer,User-Agent,Origin,Content-Type,Authorization,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers",
			"Access-Control-Allow-Credentials": "'true'",
		},
	}, nil

}

func deleteResource(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	bookingId := req.QueryStringParameters["id"]
	if bookingId == "" {
		return clientError(http.StatusBadRequest, "Expected an 'id' parameter")
	}

	err := deleteBooking(bookingId)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Access-Control-Allow-Origin":      "*",
			"Access-Control-Allow-Methods":     "GET,POST,PUT,DELETE,OPTIONS",
			"Access-Control-Allow-Headers":     "X-Amz-Date,X-Api-Key,X-Amz-Security-Token,X-Requested-With,X-Auth-Token,Referer,User-Agent,Origin,Content-Type,Authorization,Accept,Access-Control-Allow-Methods,Access-Control-Allow-Origin,Access-Control-Allow-Headers",
			"Access-Control-Allow-Credentials": "'true'",
		},
	}, nil

}

// Add a helper for handling errors. This logs any error to os.Stderr
// and returns a 500 Internal Server Error response that the AWS API
// Gateway understands.
func serverError(err error) (events.APIGatewayProxyResponse, error) {
	errorLogger.Println(err.Error())

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,
		Body:       http.StatusText(http.StatusInternalServerError),
	}, nil
}

// Similarly add a helper for send responses relating to client errors.
func clientError(status int, detail string) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: status,
		Body:       http.StatusText(status) + ": " + detail,
	}, nil
}

func IsValidUUID(u string) bool {
	_, err := uuid.Parse(u)
	return err == nil
}

func main() {
	lambda.Start(router)
}
