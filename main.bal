import ballerina_crud_application.database;
import ballerina_crud_application.email;
import ballerina_crud_application.github as gh;
import ballerina/sql;
import ballerina/http;
import ballerina/log;

service / on new http:Listener(9090) {

    // todo : change endpoint names using hypen  ex: repository\-requests
    // todo: change input parameters to a cmel case member_email -> memberEmail
    // todo:  format sql qeury to standard

    # Get all repository requests (with optional filtering by user or lead ID).
    # 
    # + memberEmail - email of the member (optional)
    # + leadEmail - email of the lead (optional)
    # + return - array of repository requests or error
    resource function get repository\-requests(string? memberEmail = (), string? leadEmail = ()) returns 
    database:RepositoryRequest[]|http:InternalServerError|http:BadRequest|http:NotFound {
        log:printInfo("Running get repository_requests() API endpoint");
        // todo: keep one function instesad of two for member and lead. use a filter for function, query function
        database:RepositoryRequest[]|error response;
        if memberEmail is string {
            log:printInfo("Fetching repository requests for member_email: " + memberEmail);
            response = database:getRepositoryRequestsByMember(memberEmail); 
        } else if leadEmail is string {
            log:printInfo("Fetching repository requests for lead_email: " + leadEmail);
            response = database:getRepositoryRequestsByLead(leadEmail); 
        } else {
            log:printError("Invalid request: Both member_email and lead_email are missing.");
            return <http:BadRequest>{
                body: "Invalid request. Please provide either member_email or lead_email."
            };
        }
        if response is error {
            log:printError("Error while retrieving repository requests: ", response);
            return <http:InternalServerError>{
                body: "Error while retrieving repository requests: " + response.message()
            };
        }
        if response.length() == 0 {
            log:printInfo("No repository requests found for the given criteria.");
            return <http:NotFound>{
                body: "No repository requests found for the given criteria."
            };
        }
        log:printInfo("Successfully retrieved repository requests.");
        return response;
    }

    // todo: handle sql no row error
    # Get a specific repository request by ID.
    # 
    # + id - ID of the repository request
    # + return - repository request object or error
    resource function get repository\-requests/[int id]() returns 
    database:RepositoryRequest|http:InternalServerError|http:NotFound {
        log:printInfo("Running get repository_request() API endpoint");

        database:RepositoryRequest|error response = database:getRepositoryRequest(id);
        if response is error {
            log:printError("Error while retrieving repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + response.message()
            };
        }
        if response.length() == 0 {
            log:printInfo("No repository request found for ID: " + id.toString());
            return <http:NotFound>{
                body: "No repository request found for the given ID."
            };
        }
        log:printInfo("Successfully retrieved repository request for ID: " + id.toString());
        return response;
    }

    # Create a new repository request.
    # 
    # + request - repository request object
    # + return - http:Created or error
    resource function post repository\-requests(database:RepositoryRequestCreate request) returns 
    http:Created|http:InternalServerError {
        log:printInfo("Running post repository_requests() API endpoint");

        database:RepositoryRequest|sql:Error response = database:insertRepositoryRequest(request);
        if response is error {
            log:printError("Error while inserting repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while inserting repository request: " + response.message()
            };
        }

        error? emailError = email:createRepoRequestMail(response);
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

        sql:ExecutionResult|sql:Error response = database:deleteRepositoryRequest(id);
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
    resource function patch repository\-requests/[int id](database:RepositoryRequestUpdate request) returns 
    http:NoContent | http:InternalServerError {
        log:printInfo("PATCH /repository_requests/" + id.toString() + " - Updating request");

        sql:ExecutionResult | sql:Error result = database:updateRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating request: " + result.message());
            return <http:InternalServerError>{ 
                body: "Internal Server Error: " + result.message() 
            };
        }

        database:RepositoryRequest|error updatedRequest = database:getRepositoryRequest(id);
        if updatedRequest is database:RepositoryRequest {
            error? emailError = email:updateRepoRequestMail(updatedRequest);
            if emailError is error {
                log:printError("Error sending email: " + emailError.message());
                return <http:InternalServerError>{ 
                    body: "Internal Server Error: " + emailError.message()
                };
            }
        }
        return http:NO_CONTENT;
    }

    // todo: make one endponits for repo request and comment updates, use filtering and jwt data to detmine
    # Update comments only.
    # 
    # + id - ID of the repository request
    # + request - repository request object
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id]/comments(database:RepositoryRequestUpdate request) returns http:NoContent|http:InternalServerError {
        log:printInfo("Running repository_requests/[int id]/comments() API endpoint");

        sql:ExecutionResult|sql:Error result = database:commentRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating comments: ", result);
            return <http:InternalServerError>{ 
                body: "Internal Server Error: " + result.message()
            };
        }

        database:RepositoryRequest|error updatedRequest = database:getRepositoryRequest(id);
        if updatedRequest is database:RepositoryRequest {
            error? emailError = email:commentRepoRequestMail(updatedRequest);
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

        database:RepositoryRequest|error repoRequest = database:getRepositoryRequest(id);
        if repoRequest is error {
            log:printError("Error while retrieving repository request: " + repoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request: " + repoRequest.message()
            };
        }

        if repoRequest.approvalState == "approved" {
            log:printInfo("Repository request is already approved.");
            return <http:BadRequest>{
                body: "Repository request is already approved."
            };
        }

        error|error[]|null repoCreationResponse = createGitHubRepository(repoRequest);
        if repoCreationResponse is error {
            log:printError("Error while creating repository on GitHub: ", repoCreationResponse);
            return <http:InternalServerError>{
                body: "Error while creating repository on GitHub" + repoCreationResponse.message()
            };
        }
        if repoCreationResponse is error[] {
            foreach error err in repoCreationResponse {
                log:printError("Error adding required parameters to repository: ", err);
            }
            return <http:InternalServerError>{
                body: "Error while creating repository on GitHub" + repoCreationResponse.toString()
            };
        }
        if repoCreationResponse is null {
            log:printInfo("Repository creation process completed successfully.");
        }

        sql:ExecutionResult|sql:Error updateApprovalState = database:approveRepositoryRequest(id); 
        if updateApprovalState is error {
            log:printError("Error while updating approval state: ", updateApprovalState);
            return <http:InternalServerError>{
                body: "Error while updating approval state: " + updateApprovalState.message()
            };
        }

        error? emailError = email:approveRepoRequestMail(repoRequest);
        if emailError is error {
            log:printError("Error while sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Error while sending email: " + emailError.message()
            };
        }
        return http:NO_CONTENT;
    }
    resource function get teams/[string org]() returns string[]|error {
        log:printInfo("Fetching teams for organization: " + org);
        return getTeams(org);
    }

    resource function post testing() returns null|string {
        log:printInfo("Testing API endpoint");
        string repoName = "bal-repo-005";
        string orgName = "gitopslab";
        string pat = database:getPat(orgName);
        error? LabelsRespnse = gh:addLabels(orgName, repoName, pat);
        if LabelsRespnse is error {
            log:printError("Error while adding labels: ", LabelsRespnse);
            return "Error while adding labels: " + LabelsRespnse.message();
        }
    }
}