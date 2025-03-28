import ballerina_crud_application.database as db;
import ballerina_crud_application.email;
// import ballerina_crud_application.github as gh;
import ballerina/sql;
import ballerina/http;
import ballerina/log;

service / on new http:Listener(9090) {

    # Get all repository requests (with filtering by user or lead ID).
    # Used to get requests to be displayed in the frontend.
    # 
    # + memberEmail - email of the member (optional)
    # + leadEmail - email of the lead (optional)
    # + return - array of repository requests or error
    resource function get repository\-requests(string? memberEmail = (), string? leadEmail = ()) returns 
    db:RepositoryRequest[]|http:InternalServerError|http:BadRequest|http:NotFound {
        log:printInfo("Running get repository_requests() API endpoint");
        // check if both memberEmail and leadEmail are null
        if memberEmail == () && leadEmail == () {
            log:printError("Both memberEmail and leadEmail cannot be null");
            return <http:BadRequest>{
                body: "Both memberEmail and leadEmail cannot be null"
            };
        }
        // get the repository requests from the database
        db:RepositoryRequest[]|sql:Error|sql:NoRowsError response = db:getRepositoryRequestsByUserOrLead(memberEmail, leadEmail);
        if response is error {
            if response is sql:NoRowsError {
                log:printInfo("No repository requests found for the given criteria.");
                return <http:NotFound>{
                    body: "No repository requests found for the given criteria."
                };
            }
            else{
                log:printError("Error while retrieving repository requests: ", response);
                return <http:InternalServerError>{
                    body: "Error while retrieving repository requests: " + response.message()
                };
            }
        }
        log:printInfo("Successfully retrieved repository requests.");
        return response;
    }

    # Get a specific repository request by ID.
    # used to get a specific request details to be displayed in the frontend.
    # 
    # + id - ID of the repository request
    # + return - repository request object or error
    resource function get repository\-requests/[int id]() returns 
    db:RepositoryRequest|http:InternalServerError|http:NotFound {
        log:printInfo("Running get repository_request() API endpoint");
        // get the repository request from the database
        db:RepositoryRequest|error response = db:getRepositoryRequest(id);
        if response is error {
            if response is sql:NoRowsError {
                log:printInfo("No repository request found with ID: " + id.toString());
                return <http:NotFound>{
                    body: "No repository request found with ID: " + id.toString()
                };
            }
            log:printError("Error while retrieving repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + response.message()
            };
        }
        log:printInfo("Successfully retrieved repository request for ID: " + id.toString());
        return response;
    }

    # Create a new repository request.
    # 
    # + request - repository request object
    # + return - http:Created or error
    resource function post repository\-requests(db:RepositoryRequestCreate request) returns 
    http:Created|http:InternalServerError {
        log:printInfo("Running post repository_requests() API endpoint");
        // insert the repository request into the database
        db:RepositoryRequest|sql:Error response = db:insertRepositoryRequest(request);
        if response is error {
            log:printError("Error while inserting repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while inserting repository request: " + response.message()
            };
        }
        // send an email notifying the creation of the repository request
        email:Request createRequestEmailObject = convertToEmailObject(response);
        error? emailError = email:createRepoRequestMail(createRequestEmailObject);
        if emailError is error {
            log:printError("Error while sending email: " + emailError.message());
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }
        log:printInfo("Email sent successfully");
        return http:CREATED;
    }

    # Delete a repository request by ID.
    # 
    # + id - ID of the repository request
    # + return - http:NoContent or error
    resource function delete repository\-requests/[int id]() returns 
    http:NoContent|http:InternalServerError {
        log:printInfo("Running delete repository_requests() API endpoint");

        sql:ExecutionResult|sql:Error response = db:deleteRepositoryRequest(id);
        if response is error {
            log:printError("Error while deleting repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while deleting repository request: " + response.message()
            };
        }
        return http:NO_CONTENT;
    }

    # Update a repository request by ID.
    # 
    # + id - ID of the repository request
    # + request - repository request object
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id](db:RepositoryRequestUpdate request) returns 
    http:NoContent | http:InternalServerError {
        log:printInfo("Running repository_requests/[int id]() API endpoint");

        // update the repository request in the database
        sql:ExecutionResult | sql:Error result = db:updateRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating request: ",result);
            return <http:InternalServerError>{ 
                body: "Internal Server Error: " + result.message() 
            };
        }
        // get the updated repository request
        db:RepositoryRequest|error updatedRequest = db:getRepositoryRequest(id);
        if updatedRequest is db:RepositoryRequest {
            // send an email notifying the update
            email:Request updateRequestEmailObject = convertToEmailObject(updatedRequest);
            error? emailError = email:updateRepoRequestMail(updateRequestEmailObject);
            if emailError is error {
                log:printError("Error sending email: ",emailError);
                return <http:InternalServerError>{ 
                    body: "Internal Server Error: " + emailError.message()
                };
            }
        }
        return http:NO_CONTENT;
    }

    // TODO: make one endponits for repo request and comment updates, use filtering and jwt data to detmine
    # Update comments only.
    # 
    # + id - ID of the repository request
    # + request - repository request object
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id]/comments(db:RepositoryRequestUpdate request) returns http:NoContent|http:InternalServerError {
        log:printInfo("Running repository_requests/[int id]/comments() API endpoint");
        // update the comments in the database
        sql:ExecutionResult|sql:Error result = db:commentRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating comments: ", result);
            return <http:InternalServerError>{ 
                body: "Internal Server Error: " + result.message()
            };
        }
        // get the updated repository request
        db:RepositoryRequest|error updatedRequest = db:getRepositoryRequest(id);
        if updatedRequest is db:RepositoryRequest {
            // send an email notifying the comment
            email:Request commentRequestEmailObject = convertToEmailObject(updatedRequest);
            error? emailError = email:commentRepoRequestMail(commentRequestEmailObject);
            if emailError is error {
                log:printError("Error sending email: ", emailError);
                return <http:InternalServerError>{ 
                    body: "Internal Server Error: " + emailError.message()
                };
            }
        }
        return http:NO_CONTENT;
    }

    # Create a repository on GitHub
    # 
    # + id - ID of the repository request
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id]/approve() returns 
    http:Response|http:InternalServerError|http:BadRequest|http:NoContent|null {
        log:printInfo("Running repository_requests/[int id]/approve() API endpoint");
        // get the repository request by ID
        db:RepositoryRequest|error repoRequest = db:getRepositoryRequest(id);
        if repoRequest is error {
            log:printError("Error while retrieving repository request: " + repoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + repoRequest.message()
            };
        }
        // check if the repository request is already approved
        if repoRequest.approvalState == "approved" {
            log:printInfo("Repository request is already approved.");
            return <http:BadRequest>{
                body: "Repository request is already approved."
            };
        }
        //create the repository on GitHub
        error|error[]|null repoCreationResponse = createGitHubRepository(repoRequest);
        // check if there are any errors while creating the repository
        if repoCreationResponse is error {
            log:printError("Error while creating repository on GitHub: ", repoCreationResponse);
            return <http:InternalServerError>{
                body: "Error while creating repository on GitHub" + repoCreationResponse.message()
            };
        }
        // check if there are any errors while adding required parameters to the repository
        if repoCreationResponse is error[] {
            foreach error err in repoCreationResponse {
                log:printError("Error adding required parameters to repository: ", err);
            }
            return <http:InternalServerError>{
                body: "Error while creating repository on GitHub" + repoCreationResponse.toString()
            };
        }
        // check if the repository creation process completed successfully
        if repoCreationResponse is null {
            log:printInfo("Repository creation process completed successfully.");
        }
        // update the approval state of the repository request
        sql:ExecutionResult|sql:Error updateApprovalState = db:approveRepositoryRequest(id); 
        if updateApprovalState is error {
            log:printError("Error while updating approval state: ", updateApprovalState);
            return <http:InternalServerError>{
                body: "Error while updating approval state: " + updateApprovalState.message()
            };
        }
        // send an email to the user notifying them about the approval
        email:Request approveRepoRequestEmailObject = convertToEmailObject(repoRequest);
        error? emailError = email:approveRepoRequestMail(approveRepoRequestEmailObject);
        if emailError is error {
            log:printError("Error while sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }
        return http:NO_CONTENT;
    }

    # return the list of internal commiter treams in a GitHub organization. 
    # Used to update frontend forms
    # 
    # + org - selected organization
    # + return - list of teams
    resource function get teams/[string org]() returns string[]|error {
        log:printInfo("Fetching teams for organization: " + org);
        return getTeams(org);
    }

    resource function post testing() returns null|string {
        db:RepositoryRequest|error repoRequest = db:getRepositoryRequest(5);
        if repoRequest is db:RepositoryRequest {
            email:Request response = convertToEmailObject(repoRequest);
            error? emailError1 = email:createRepoRequestMail(response);
            if emailError1 is error {
                log:printError("Error while sending email: " + emailError1.message());
            }
            else{
                log:printInfo("Email 1 sent successfully");
            }
            
            error? emailError2 = email:updateRepoRequestMail(response);
            if emailError2 is error {
                log:printError("Error while sending email: " + emailError2.message());
            }
            else{
                log:printInfo("Email 2 sent successfully");
            }
            error? emailError3 = email:commentRepoRequestMail(response);
            if emailError3 is error {
                log:printError("Error while sending email: " + emailError3.message());
            }
            else{
                log:printInfo("Email 3 sent successfully");
            }
            error? emailError4 = email:approveRepoRequestMail(response);
            if emailError4 is error {
                log:printError("Error while sending email: " + emailError4.message());
            }
            else{
                log:printInfo("Email 4 sent successfully");
            }
            
        }
    }
}