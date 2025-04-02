// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import github_repo_manager.database as db;
import github_repo_manager.email;

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
        returns http:Ok|http:InternalServerError|http:NotFound {
        log:printInfo("Running repository_requests/[int id]() API endpoint");

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
        returns http:Ok|http:InternalServerError|http:NotFound {

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
        map<string> payload = createKeyValuePair(repoRequest);
        error? emailError = email:approveRepoRequestAlert(payload);
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
        db:RepositoryRequest|error|null repoRequest = db:getRepositoryRequest(4);
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
        error? emailError1 = email:createRepoRequestAlert(payload);
        if emailError1 is error {
            log:printError("Error while sending email1: " + emailError1.message());
            return "Error while sending email1: " + emailError1.message();
        }
        log:printInfo("Email1 sent successfully");
        error? emailError2 = email:updateRepoRequestAlert(payload);
        if emailError2 is error {
            log:printError("Error while sending email1: " + emailError2.message());
            return "Error while sending email1: " + emailError2.message();
        }
        log:printInfo("Email1 sent successfully");
        error? emailError3 = email:commentRepoRequestAlert(payload);
        if emailError3 is error {
            log:printError("Error while sending email1: " + emailError3.message());
            return "Error while sending email1: " + emailError3.message();
        }
        log:printInfo("Email1 sent successfully");
        error? emailError4 = email:approveRepoRequestAlert(payload);
        if emailError4 is error {
            log:printError("Error while sending email1: " + emailError4.message());
            return "Error while sending email1: " + emailError4.message();
        }
        log:printInfo("Email1 sent successfully");
    }
}
