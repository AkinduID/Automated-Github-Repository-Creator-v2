import ballerina/sql;
import ballerina/io;

# Get the personal access token (PAT) for the organization.
# 
# + organization - organization name
# + return - Personal Access Token (PAT) for the organization
public isolated function getPat(string organization) returns string {
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
public isolated function getRepositoryRequest(int id) returns RepositoryRequest|sql:Error {
    io:println(" - Running getRepositoryRequest() Function");
    RepositoryRequest|sql:Error result = dbClient->queryRow(getRepositoryRequestQuery(id));
    io:println("   - Result: ", result);
    return result;
}


# Get all repository requests created by a user (member or lead).
# 
# + member_email - member email
# + return - repository requests created by the user or sql:Error
public isolated function getRepositoryRequestsByMember(string member_email) returns RepositoryRequest[]|sql:Error {
    io:println(" - Running getRepositoryRequestsByUser() Function");
    stream<RepositoryRequest, sql:Error?> resultStream = dbClient->query(getRepositoryRequestsByUserQuery(member_email));
    io:println("   - Result Stream: ", resultStream);
    RepositoryRequest[] repositoryRequests = [];
    check from RepositoryRequest repositoryRequest in resultStream
        do {
            repositoryRequests.push(repositoryRequest);
        };
    return repositoryRequests;
}


# Get all repository requests for a lead.
# 
# + lead_email - lead email
# + return - repository requests for the lead or sql:Error
public isolated function getRepositoryRequestsByLead(string lead_email) returns RepositoryRequest[]|sql:Error {
    io:println(" - Running getRepositoryRequestsByLead() Function");
    stream<RepositoryRequest, sql:Error?> resultStream = dbClient->query(getRepositoryRequestsByLeadQuery(lead_email));
    io:println("   - Result Stream: ", resultStream);
    RepositoryRequest[] repositoryRequests = [];
    check from RepositoryRequest repositoryRequest in resultStream
        do {
            repositoryRequests.push(repositoryRequest);
        };
    return repositoryRequests;
}

# insert a new repository request into the database.
# 
# + payload - repository request payload
# + return - newly inserted RepositoryRequest object or sql:Error
public isolated function insertRepositoryRequest(RepositoryRequestCreate payload) returns RepositoryRequest|sql:Error {
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
public isolated function deleteRepositoryRequest(int requestId) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running deleteRepositoryRequests() Function");
    return dbClient->execute(deleteRepositoryRequestQuery(requestId));
}

# Update a repository request in the database.
# 
# + requestId - repository request ID  
# + payload - repository request payload
# + return - ExecutionResult or sql:Error
public isolated function updateRepositoryRequest(int requestId, RepositoryRequestUpdate payload) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running updateRepositoryRequests() Function");
    return dbClient->execute(updateRepositoryRequestQuery(requestId, payload));
}

# Update comment a repository request in the database.
# 
# + requestId - repository request ID
# + payload - repository request payload. contains only comment field
# + return - ExecutionResult or sql:Error
public isolated function commentRepositoryRequest(int requestId, RepositoryRequestUpdate payload) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running commentRepositoryRequests() Function");
    return dbClient->execute(commentRepositoryRequestQuery(requestId, payload));
}


# Change approval state a repository request in the database.
# 
# + requestId - repository request ID
# + return - ExecutionResult or sql:Error
public isolated function approveRepositoryRequest(int requestId) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running approveRepositoryRequests() Function");
    return dbClient->execute(approveRepositoryRequestQuery(requestId));
}