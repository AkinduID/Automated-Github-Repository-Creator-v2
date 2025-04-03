// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import github_repo_manager.database as db;
import github_repo_manager.email;
import github_repo_manager.github as gh;

import ballerina/http;
import ballerina/log;
import ballerina/sql;

service / on new http:Listener(9090) {

    # Get all repository requests (with filtering by user or lead ID).
    # Used to get requests to be displayed in the frontend.
    #
    # + memberEmail - email of the member (optional)
    # + leadEmail - email of the lead (optional)
    # + return - array of repository requests or error
    resource function get repository\-requests(string? memberEmail = (), string? leadEmail = ())
        returns db:RepositoryRequest[]|http:InternalServerError|http:BadRequest|http:NotFound {

        log:printInfo("Running get repository_requests() API endpoint");
        // check if both memberEmail and leadEmail are null
        if memberEmail == () && leadEmail == () {
            log:printError("Both memberEmail and leadEmail cannot be null");
            return <http:BadRequest>{
                body: "Both memberEmail and leadEmail cannot be null"
            };
        }
        // get the repository requests from the database
        db:RepositoryRequest[]|sql:Error repoRequests = db:getRepositoryRequests(memberEmail, leadEmail);
        if repoRequests is error {
            log:printError("Error while retrieving repository requests: ", repoRequests);
            return <http:InternalServerError>{
                body: "Error while retrieving repository requests"
            };
        }
        log:printInfo("Successfully retrieved repository requests.");
        return repoRequests;
    }

    # Get a specific repository request by ID.
    # used to get a specific request details to be displayed in the frontend.
    #
    # + id - ID of the repository request
    # + return - repository request object or error
    resource function get repository\-requests/[int id]()
        returns db:RepositoryRequest|http:InternalServerError|http:NotFound {

        log:printInfo("Running get repository_request() API endpoint");
        // get the repository request from the database
        db:RepositoryRequest|error|null repoRequest = db:getRepositoryRequest(id);
        if repoRequest is error {
            log:printError("Error while retrieving repository request: " + repoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if repoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        log:printInfo("Successfully retrieved repository request for ID: " + id.toString());
        return repoRequest;
    }

    # Create a new repository request.
    #
    # + request - repository request object
    # + return - http:Created or error
    resource function post repository\-requests(db:RepositoryRequestCreate request)
        returns http:Created|http:InternalServerError {

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
        map<string> payload = createKeyValuePair(response); //TODO: 
        error? emailError = email:createRepoRequestAlert(payload);
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
    resource function delete repository\-requests/[int id]()
        returns http:Ok|http:InternalServerError {

        log:printInfo(`Deleting repo request with id${id}`); //deleting repo reques with id
        sql:ExecutionResult|sql:Error response = db:deleteRepositoryRequest(id);
        if response is error {
            log:printError("Error while deleting repository request: " + response.message());
            return <http:InternalServerError>{
                body: "Error while deleting repository request: " + response.message()
            };
        }
        return http:OK;
    }

    # Update a repository request by ID.
    #
    # + id - ID of the repository request
    # + request - repository request object
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id](db:RepositoryRequestUpdate request)
        returns http:Ok|http:InternalServerError|http:NotFound|http:BadRequest {

        log:printInfo("Running repository_requests/[int id]() API endpoint");
        // get the current repository request by id
        db:RepositoryRequest|error|null RepoRequest = db:getRepositoryRequest(id);
        if RepoRequest is error {
            log:printError("Error while retrieving repository request: " + RepoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if RepoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        if RepoRequest.approvalState == "Approved" {
            log:printWarn("Repository request is already approved.");
            return <http:BadRequest>{
                body: "Repository request is already approved."
            };
        }
        if RepoRequest.approvalState == "Pending" {
            log:printWarn("Repository request is pending review.");
            return <http:BadRequest>{
                body: "Repository request is pending review."
            };
        }
        // update the repository request in the database
        sql:ExecutionResult|sql:Error result = db:updateRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating request: ", result);
            return <http:InternalServerError>{
                body: "Internal Server Error: " + result.message()
            };
        }
        // get the updated repository request
        db:RepositoryRequest|error|null updatedRepoRequest = db:getRepositoryRequest(id);
        if updatedRepoRequest is error {
            log:printError("Error while retrieving repository request: " + updatedRepoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if updatedRepoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        // send an email notifying the comment
        map<string> payload = createKeyValuePair(updatedRepoRequest);
        error? emailError = email:commentRepoRequestAlert(payload);
        if emailError is error {
            log:printError("Error sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Internal Server Error: " + emailError.message()
            };
        }
        return http:OK;
    }

    // TODO: make one endponits for repo request and comment updates, use filtering and jwt data to detmine.
    # Update comments only.
    #
    # + id - ID of the repository request
    # + request - repository request object
    # + return - http:NoContent or error
    resource function patch repository\-requests/[int id]/comments(db:RepositoryRequestUpdate request)
        returns http:Ok|http:InternalServerError|http:NotFound|http:BadRequest {

        log:printInfo("Running repository_requests/[int id]/comments() API endpoint");
        // get the current repository request by id
        db:RepositoryRequest|error|null RepoRequest = db:getRepositoryRequest(id);
        if RepoRequest is error {
            log:printError("Error while retrieving repository request: " + RepoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if RepoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        if RepoRequest.approvalState == "Approved" {
            log:printWarn("Repository request is already approved.");
            return <http:BadRequest>{
                body: "Repository request is already approved."
            };
        }
        if RepoRequest.approvalState == "Rejected" {
            log:printWarn("Repository request is pending changes");
            return <http:BadRequest>{
                body: "Repository request is pending changes."
            };
        }
        // update the comments in the database
        sql:ExecutionResult|sql:Error result = db:commentRepositoryRequest(id, request);
        if result is error {
            log:printError("Error updating comments: ", result);
            return <http:InternalServerError>{
                body: "Internal Server Error: " + result.message()
            };
        }
        // get the updated repository request
        db:RepositoryRequest|error|null updatedRepoRequest = db:getRepositoryRequest(id);
        if updatedRepoRequest is error {
            log:printError("Error while retrieving repository request: " + updatedRepoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if updatedRepoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        // send an email notifying the comment
        map<string> payload = createKeyValuePair(updatedRepoRequest);
        error? emailError = email:commentRepoRequestAlert(payload);
        if emailError is error {
            log:printError("Error sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Internal Server Error: " + emailError.message()
            };
        }
        return http:OK;
    }

    # Create a repository on GitHub
    #
    # + id - ID of the repository request
    # + return - http:NoContent or error
    isolated resource function post repository\-requests/[int id]/approve()
        returns http:Ok|http:InternalServerError|http:BadRequest|http:NotFound|null {

        log:printInfo(`Approving repository request with ID: ${id}`);
        // get the repository request by ID
        db:RepositoryRequest|error|null repoRequest = db:getRepositoryRequest(id);
        if repoRequest is error {
            log:printError("Error while retrieving repository request: " + repoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if repoRequest is null {
            log:printWarn("No repository request found with ID: " + id.toString());
            return <http:NotFound>{
                body: string `No repository request found with ID: ${id}`
            };
        }
        // check if the repository request is already approved
        if repoRequest.approvalState == "Approved" {
            log:printInfo("Repository request is already approved.");
            return <http:BadRequest>{
                body: "Repository request is already approved."
            };
        }
        if repoRequest.approvalState == "Rejected" {
            log:printInfo("Repository request requires updates");
            return <http:BadRequest>{
                body: "Repository request requires updates."
            };
        }
        //create the repository on GitHub
        gh:gitHubOperationResult[] repoCreationResponse = createGitHubRepository(repoRequest);
        // check if there are any errors while creating the repository
        foreach gh:gitHubOperationResult result in repoCreationResponse {
            if result.operation == "Create Repository" && result.status == "error" {
                log:printError(`Error: ", ${result.operation}`);
                return <http:InternalServerError>{
                    body: string `Error while creating repository: ${result.errorMessage.toString()}`
                };
            }
            else if result.status == "error" {
                log:printWarn(`Error: ", ${result.operation}`);
            }
            else if result.status == "success" {
                log:printInfo(`Success: ", ${result.operation}`);
            }
        }
        log:printInfo("Repository creation process completed successfully.");
        // update the approval state of the repository request
        sql:ExecutionResult|sql:Error updateApprovalState = db:approveRepositoryRequest(id);
        if updateApprovalState is error {
            log:printError("Error while updating approval state: ", updateApprovalState);
            return <http:InternalServerError>{
                body: "Error while updating approval state"
            };
        }
        // send an email to the user notifying them about the approval
        map<string> ghreport = getGhStatusReport(repoCreationResponse);
        map<string> payload = createKeyValuePair(repoRequest);
        error? emailError = email:approveRepoRequestAlert(payload, ghreport);
        if emailError is error {
            log:printError("Error while sending email: ", emailError);
            return <http:InternalServerError>{
                body: "Error while sending email"
            };
        }
        return http:OK;
    }

    # return the list of internal commiter treams in a GitHub organization. 
    # Used to update frontend forms
    #
    # + organization - selected organization
    # + return - list of teams
    resource function get teams/[string organization]()
        returns string[]|error {

        log:printInfo(`Fetching teams for organization: ${organization}`);
        return getTeams(organization);
    }

    resource function post testing()
        returns null|string|http:InternalServerError|http:NotFound {

        log:printInfo("Running testing() API endpoint");
        gh:gitHubOperationResult[] testResults = [
            {
                operation: "Create Repository",
                status: "success",
                errorMessage: ()
            },
            {
                operation: "Add Topics",
                status: "failure",
                errorMessage: "Failed to add topics due to API error"
            },
            {
                operation: "Add Labels Type/Bug",
                status: "success",
                errorMessage: ()
            },
            {
                operation: "Add Labels Type/New Feature",
                status: "success",
                errorMessage: ()
            },
            {
                operation: "Add Issue Template",
                status: "failure",
                errorMessage: "Issue template file not found"
            },
            {
                operation: "Add PR Template",
                status: "success",
                errorMessage: ()
            },
            {
                operation: "Add Teams gitopslab-all",
                status: "success",
                errorMessage: ()
            },
            {
                operation: "Add Teams gitopslab-all-interns",
                status: "failure",
                errorMessage: "Permission denied for adding team"
            }
        ];
        db:RepositoryRequest|error|null repoRequest = db:getRepositoryRequest(1);
        if repoRequest is error {
            log:printError("Error while retrieving repository request: " + repoRequest.message());
            return <http:InternalServerError>{
                body: "Error while retrieving repository request:"
            };
        }
        if repoRequest is null {
            log:printInfo("No repository request found with ID: "); //print warning
            return <http:NotFound>{
                body: string `No repository request found with ID:`
            };
        }
        log:printInfo("Successfully retrieved repository request: " + repoRequest.toString());
        map<string> payload = createKeyValuePair(repoRequest);
        map<string> ghreport = getGhStatusReport(testResults);

        log:printInfo("Email1 sent successfully");
        error? emailError4 = email:approveRepoRequestAlert(payload, ghreport);
        if emailError4 is error {
            log:printError("Error while sending email1: " + emailError4.message());
            return "Error while sending email1: " + emailError4.message();
        }
        log:printInfo("Email1 sent successfully");
    }
}
