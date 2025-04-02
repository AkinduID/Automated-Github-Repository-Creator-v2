// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/io;
import ballerina/sql;

// import github_repo_manager.shared;

# Get the personal access token (PAT) for the organization.
#
# + organization - organization name
# + return - Personal Access Token (PAT) for the organization
public isolated function getPat(string organization)
    returns string {

    io:println(" - Running getPat() Function");
    // Execute the query and return a stream of RepositoryRequest records.
    string|sql:Error result = dbClient->queryRow(getPatQuery(organization));
    io:println("   - Result: ", result);
    if result is sql:Error {
        io:println("   - Error: ", result);
        return "";
    }
    else {
        return result;
    }
}

# Get a specific repository request by id.
#
# + id - Repository request id
# + return - RepositoryRequest object
public isolated function getRepositoryRequest(int id)
    returns RepositoryRequest|error|null {

    io:println(" - Running getRepositoryRequest() Function");
    RepositoryRequest|sql:Error result = dbClient->queryRow(getRepositoryRequestQuery(id));
    io:println("   - Result: ", result);
    if result is sql:NoRowsError {
        return null;
    }
    return result;
}

# Get all repository requests created by a user (member or lead).
#
# + memberEmail - member email
# + leadEmail - lead email
# + return - repository requests created by the user or sql:Error
public isolated function getRepositoryRequests(string? memberEmail, string? leadEmail)
    returns RepositoryRequest[]|sql:Error {

    io:println(" - Running getRepositoryRequestsByUserOrLead() Function");
    stream<RepositoryRequest, sql:Error?> resultStream = dbClient->query(getRepositoryRequestsQuery(memberEmail, leadEmail));
    io:println("   - Result Stream: ", resultStream);
    RepositoryRequest[] repositoryRequests = [];
    check from RepositoryRequest repositoryRequest in resultStream
        do { // TODO: use select keyword
            repositoryRequests.push(repositoryRequest);
        };
    return repositoryRequests;
}

# insert a new repository request into the database.
#
# + payload - repository request payload
# + return - newly inserted RepositoryRequest object or sql:Error
public isolated function insertRepositoryRequest(RepositoryRequestCreate payload)
    returns RepositoryRequest|sql:Error {

    io:println(" - Running insertRepositoryRequests() Function");

    // Execute the INSERT query
    sql:ExecutionResult|sql:Error result = dbClient->execute(insertRepositoryRequestQuery(payload));
    if result is sql:Error {
        io:println("   - Error while inserting: ", result.message());
        return result;
    }

    // Retrieve the last inserted ID
    int|sql:Error lastInsertId = dbClient->queryRow(`SELECT LAST_INSERT_ID()`);
    if lastInsertId is sql:Error {
        io:println("   - Error while retrieving last insert ID: ", lastInsertId.message());
        return lastInsertId;
    }

    // Fetch the newly inserted row using the last inserted ID
    RepositoryRequest|sql:Error newRow = dbClient->queryRow(getRepositoryRequestQuery(lastInsertId));
    if newRow is sql:Error {
        io:println("   - Error while retrieving the newly inserted row: ", newRow.message());
        return newRow;
    }

    io:println("   - Successfully inserted. New Row: ", newRow);
    return newRow;
}

# Delete a repository request from the database.
#
# + requestId - repository request ID
# + return - ExecutionResult or sql:Error
public isolated function deleteRepositoryRequest(int requestId)
    returns sql:ExecutionResult|sql:Error {

    io:println(" - Running deleteRepositoryRequests() Function");
    return dbClient->execute(deleteRepositoryRequestQuery(requestId));
}

# Update a repository request in the database.
#
# + requestId - repository request ID  
# + payload - repository request payload
# + return - ExecutionResult or sql:Error
public isolated function updateRepositoryRequest(int requestId, RepositoryRequestUpdate payload)
    returns sql:ExecutionResult|sql:Error {

    io:println(" - Running updateRepositoryRequests() Function");
    return dbClient->execute(updateRepositoryRequestQuery(requestId, payload));
}

# Update comment a repository request in the database.
#
# + requestId - repository request ID
# + payload - repository request payload. contains only comment field
# + return - ExecutionResult or sql:Error
public isolated function commentRepositoryRequest(int requestId, RepositoryRequestUpdate payload)
    returns sql:ExecutionResult|sql:Error {

    io:println(" - Running commentRepositoryRequests() Function");
    return dbClient->execute(commentRepositoryRequestQuery(requestId, payload));
}

# Change approval state a repository request in the database.
#
# + requestId - repository request ID
# + return - ExecutionResult or sql:Error
public isolated function approveRepositoryRequest(int requestId)
    returns sql:ExecutionResult|sql:Error {

    io:println(" - Running approveRepositoryRequests() Function");
    return dbClient->execute(approveRepositoryRequestQuery(requestId));
}
