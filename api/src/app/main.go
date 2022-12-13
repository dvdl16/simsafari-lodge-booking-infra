package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

var uuidRegexp = regexp.MustCompile(`^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$`)
var errorLogger = log.New(os.Stderr, "ERROR ", log.Llongfile)
var debugLogger = log.New(os.Stderr, "DEBUG ", log.Llongfile)

type booking struct {
	BookingId    string   `json:"bookingId"`
	UserId       string   `json:"userId"`
	FromDate     string   `json:"fromDate"`
	ToDate       string   `json:"toDate"`
	Houses       []string `json:"houses` // Type SS (String Set) in DynamoDB
	GuestDetails string   `json:"guestDetails"`
}

// Do a switch on the HTTP request method to determine which action to take.
func router(req events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	debugLogger.Println("req.RequestContext.HTTP.Method:")
	debugLogger.Println(req.RequestContext.HTTP.Method)
	switch req.RequestContext.HTTP.Method {
	case "GET":
		return show(req)
	case "POST":
		return create(req)
	default:
		return clientError(http.StatusMethodNotAllowed, "Only GET and POST allowed")
	}
}

func show(req events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	// Get the `bookingId` query string parameter from the request and
	// validate it.
	bookingId := req.QueryStringParameters["bookingId"]
	if !uuidRegexp.MatchString(bookingId) {
		return clientError(http.StatusBadRequest, "Invalid bookingId")
	}

	// Fetch the booking record from the database based on the bookingId value.
	bk, err := getItem(bookingId)
	if err != nil {
		return serverError(err)
	}
	if bk == nil {
		return clientError(http.StatusNotFound, "Booking not found")
	}

	// The APIGatewayProxyResponse.Body field needs to be a string, so
	// we marshal the booking record into JSON.
	js, err := json.Marshal(bk)
	if err != nil {
		return serverError(err)
	}

	// Return a response with a 200 OK status and the JSON booking record
	// as the body.
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Body:       string(js),
	}, nil
}

func create(req events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
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

	// TODO Generate UUID booking ID
	if !uuidRegexp.MatchString(bk.BookingId) {
		return clientError(http.StatusBadRequest, "Invalid booking ID")
	}
	if bk.GuestDetails == "" || bk.GuestDetails == "" {
		return clientError(http.StatusBadRequest, "Guest Details cannot be empty")
	}

	err = putItem(bk)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 201,
		Headers:    map[string]string{"Location": fmt.Sprintf("/books?bookingId=%s", bk.BookingId)},
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

func main() {
	lambda.Start(router)
}
