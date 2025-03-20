import ballerina_crud_application.database;
import ballerina/sql;
import ballerina/http;
import ballerina/io;
service / on new http:Listener(9090) {

    // Resource function to get all repository requests.
    resource function get repository_requests() returns database:RepositoryRequest[]|http:InternalServerError {
        io:println("Running get repository_requests() API endpoint");
        // Call the getRepositoryRequests function to fetch data from the database.
        database:RepositoryRequest[]|error response = database:getRepositoryRequests();
        io:println("Response from getRepositoryRequests: ", response);

        // If there's an error while fetching, return an internal server error.
        if response is error {
            io:println("Error while retrieving repository requests: ", response);
            return <http:InternalServerError>{
                body: "Error while retrieving repository requests" + response.message()
            };
        }

        // Return the response containing the list of repository requests.
        return response;
    }

    // Resource function to insert a new repository request.
    resource function post repository_requests(database:RepositoryRequestCreate request) returns http:Created|http:InternalServerError {
        io:println("Running post repository_requests() API endpoint");
        sql:ExecutionResult|sql:Error response = database:insertRepositoryRequest(request);
        io:println("Response from insertRepositoryRequests: ", response);
        
        // If there's an error while inserting, return an internal server error.
        if response is error {
            return <http:InternalServerError>{
                body: "Error while inserting repository request"
            };
        }
        
        // Return HTTP CREATED response after successful insertion.
        return http:CREATED;
    }

    // Resource function to delete a repository request by ID.
    resource function delete repository_requests/[int id]() returns http:NoContent|http:InternalServerError {
        io:println("Running delete repository_requests() API endpoint");
        sql:ExecutionResult|sql:Error response = database:deleteRepositoryRequest(id);

        // If there's an error while deleting, return an internal server error.
        if response is error {
            return <http:InternalServerError>{
                body: "Error while deleting repository request"
            };
        }

        // Return HTTP NO CONTENT response after successful deletion.
        return http:NO_CONTENT;
    }

    // Resource function to update a repository request by ID.
    resource function patch repository_requests/[int id](database:RepositoryRequestUpdate request) returns http:NoContent|http:InternalServerError {
        io:println("Running patch repository_requests() API endpoint");
        sql:ExecutionResult|sql:Error response = database:updateRepositoryRequest(id, request);

        // If there's an error while updating, return an internal server error.
        if response is error {
            return <http:InternalServerError>{
                body: "Error while updating repository request"
            };
        }

        // Return HTTP NO CONTENT response after successful update.
        return http:NO_CONTENT;
    }
}
