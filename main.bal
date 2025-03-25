import ballerina_crud_application.database;
import ballerina_crud_application.gh;
import ballerina_crud_application.email;
import ballerina/sql;
import ballerina/http;
import ballerina/io;
// import ballerina/log;

service / on new http:Listener(9090) {

    // Get all repository requests (with optional filtering by user or lead ID)
    resource function get repository_requests(string? member_email = (), string? lead_email = ()) returns 
    database:RepositoryRequest[] |http:InternalServerError |http:BadRequest |http:NotFound {
        io:println("Running get repository_requests() API endpoint");

        database:RepositoryRequest[]|error response;
        if member_email is string {
            io:println("Fetching repository requests for member_email: " + member_email);
            response = database:getRepositoryRequestsByMember(member_email); 
        } else if lead_email is string {
            io:println("Fetching repository requests for lead_email: " + lead_email);
            response = database:getRepositoryRequestsByLead(lead_email); 
        } else {
            io:println("Invalid request: Both member_email and lead_email are missing.");
            return <http:BadRequest>{
                body: "Invalid request. Please provide either member_email or lead_email."
            };
        }
        if response is error {
            io:println("Error while retrieving repository requests: ", response);
            return <http:InternalServerError>{
                body: "Error while retrieving repository requests: " + response.message()
            };
        }
        if response.length() == 0 {
            io:println("No repository requests found for the given criteria.");
            return <http:NotFound>{
                body: "No repository requests found for the given criteria."
            };
        }
        io:println("Successfully retrieved repository requests: ");
        return response;
}

    // Get a specific repository request by ID
    resource function get repository_requests/[int id]() returns 
    database:RepositoryRequest|http:InternalServerError|http:NotFound {
        io:println("Running get repository_request() API endpoint");

        database:RepositoryRequest|error response = database:getRepositoryRequest(id);
        if response is error {
            io:println("Error while retrieving repository request: ", response.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + response.message()
            };
        }
        if response.length()==0 {
            io:println("No repository request found for ID: ", id);
            return <http:NotFound>{
                body: "No repository request found for the given ID."
            };
        }
        io:println("Successfully retrieved repository request for ID: ", id);
        return response;
    }

    // Create a new repository request
    resource function post repository_requests(database:RepositoryRequestCreate request) returns 
    http:Created|http:InternalServerError {
        io:println("Running post repository_requests() API endpoint");

        database:RepositoryRequest|sql:Error response = database:insertRepositoryRequest(request);
        if response is error {
            io:println("Error while inserting repository request: ", response.message());
            return <http:InternalServerError>{
                body: "Error while inserting repository request: " + response.message()
            };
        }

        error? emailError = email:createRepoRequestMail(response);
        if emailError is error {
            io:println("Error while sending email: ", emailError.message());
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }
        io:println("Email sent successfully");
        return http:CREATED;
    }

    // Delete a repository request by ID
    resource function delete repository_requests/[int id]() returns 
    http:NoContent|http:InternalServerError {
        io:println("Running delete repository_requests() API endpoint");

        sql:ExecutionResult|sql:Error response = database:deleteRepositoryRequest(id);
        if response is error {
            return <http:InternalServerError>{
                body: "Error while deleting repository request: " + response.message()
            };
        }
        return http:NO_CONTENT;
    }

    // Update a repository request by ID
    resource function patch repository_requests/[int id](database:RepositoryRequestUpdate request) returns 
    http:NoContent | http:InternalServerError {
        io:println("PATCH /repository_requests/" + id.toString() + " - Updating request");
        //Update Database Entry
        sql:ExecutionResult | sql:Error result = database:updateRepositoryRequest(id, request);
        if (result is error) {
            io:println("Error updating request: " + result.message());
            return <http:InternalServerError>{ 
                body: "Internal Server Error: " + result.message() 
            };
        }

        //Get the updated request
        database:RepositoryRequest|error updatedRequest = database:getRepositoryRequest(id);
        if updatedRequest is database:RepositoryRequest{

            //Send email notification
            error? emailError = email:updateRepoRequestMail(updatedRequest);
            if emailError is error {
                io:println("Error sending email: " + emailError.message());
                return <http:InternalServerError>{ 
                    body: "Internal Server Error: " + emailError.message()
                };
            }
        }
        return http:NO_CONTENT;
    }

    //update comments only.
    resource function patch repository_requests/[int id]/comments(database:RepositoryRequestUpdate request) returns 
    http:NoContent|http:InternalServerError{
        io:println("PATCH /repository_requests/" + id.toString() + "/comments - Updating comments");

        //Update Database Entry
        sql:ExecutionResult | sql:Error result = database:commentRepositoryRequest(id, request);
        if (result is error) {
            io:println("Error updating comments: " + result.message());
            return <http:InternalServerError>{ 
                body: "Internal Server Error" + result.message()
            };
        }
        //Get the updated request
        database:RepositoryRequest|error updatedRequest = database:getRepositoryRequest(id);
        if updatedRequest is database:RepositoryRequest{

            //Send email notification
            error? emailError = email:commentRepoRequestMail(updatedRequest);
            if emailError is error {
                io:println("Error sending email: " + emailError.message());
                return <http:InternalServerError>{ 
                    body: "Internal Server Error" + emailError.message()
                };
            }
        }
        return http:NO_CONTENT;
    }
    

    // Create a repository on GitHub
    resource function patch repository_requests/[int id]/approve() returns 
    http:Response|http:InternalServerError {
        io:println("Running repository_requests/[int id]/approve() API endpoint");

        // Get the repository request from the database
        database:RepositoryRequest|error repoRequest = database:getRepositoryRequest(id);
        if repoRequest is error {
            io:println("Error while retrieving repository request: ", repoRequest);
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + repoRequest.message()
            };
        }

        // Create Repository on GitHub
        http:Response | error repoCreationResponse = gh:createGitHubRepository(repoRequest);
        if repoCreationResponse is error {
            io:println("Error while creating repository on GitHub: ", repoCreationResponse);
            return <http:InternalServerError>{
                body: "Error while creating repository on GitHub" 
            };
        }

        //update the approval state in the database
        sql:ExecutionResult|sql:Error updateApprovalState= database:approveRepositoryRequest(id); 
        if updateApprovalState is error {
            io:println("Error while updating approval state: ", updateApprovalState.message());
            return <http:InternalServerError>{
                body: "Error while updating approval state: " + updateApprovalState.message()
            };
        }

        // send email notification
        error? emailError = email:approveRepoRequestMail(repoRequest);
        if emailError is error {
            io:println("Error while sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }

        return repoCreationResponse; // Returning the first response. You might need to handle responses differently.
    }


    resource function post emailtest() 
    returns http:Response|database:RepositoryRequest|http:InternalServerError|error {
        io:println("Running test() API endpoint");

        database:RepositoryRequest|error repoRequest = database:getRepositoryRequest(7);
        if repoRequest is error {
            io:println("Error while retrieving repository request: ", repoRequest);
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + repoRequest.message()
            };
        }

        error? emailError = email:createRepoRequestMail(repoRequest);
        if emailError is error {
            io:println("Error while sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }
        return repoRequest;

    }
}