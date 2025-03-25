import ballerina/sql;
import ballerina/io;

// Define the function to fetch repository requests from the database.

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

# Description.
#
# + id - parameter description
# + return - return value description
public isolated function getRepositoryRequest(int id) returns RepositoryRequest|sql:Error {
    io:println(" - Running getRepositoryRequest() Function");
    RepositoryRequest|sql:Error result = dbClient->queryRow(getRepositoryRequestQuery(id));
    io:println("   - Result: ", result);
    return result;
}


# Description.
#
# + member_email - parameter description
# + return - return value description
public isolated function getRepositoryRequestsByUser(string member_email) returns RepositoryRequest[]|sql:Error {
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


# Description.
#
# + lead_email - parameter description
# + return - return value description
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

# Description.
# get all repository requests 
# + return - return value description
public isolated function getAllRepositoryRequests() returns RepositoryRequest[]|sql:Error {
    io:println(" - Running getAllRepositoryRequests() Function");
    stream<RepositoryRequest, sql:Error?> resultStream = dbClient->query(getAllRepositoryRequestsQuery());
    io:println("   - Result Stream: ", resultStream);
    RepositoryRequest[] repositoryRequests = [];
    check from RepositoryRequest repositoryRequest in resultStream
        do {
            repositoryRequests.push(repositoryRequest);
        };
    return repositoryRequests;
}

# Description.
# insert a new repository request into the database.
# + payload - parameter description
# + return - return value description
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

// Delete a repository request from the database by ID.
# Description.
#
# + requestId - parameter description
# + return - return value description
public isolated function deleteRepositoryRequest(int requestId) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running deleteRepositoryRequests() Function");
    return dbClient->execute(deleteRepositoryRequestQuery(requestId));
}

// Update a repository request in the database.
# Description.
#
# + requestId - parameter description  
# + payload - parameter description
# + return - return value description
public isolated function updateRepositoryRequest(int requestId, RepositoryRequestUpdate payload) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running updateRepositoryRequests() Function");
    return dbClient->execute(updateRepositoryRequestQuery(requestId, payload));
}

public isolated function commentRepositoryRequest(int requestId, RepositoryRequestUpdate payload) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running updateRepositoryRequests() Function");
    return dbClient->execute(commentRepositoryRequestQuery(requestId, payload));
}

public isolated function approveRepositoryRequest(int requestId) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running updateRepositoryRequests() Function");
    return dbClient->execute(approveRepositoryRequestQuery(requestId));
}