import ballerina/sql;
import ballerina/io;

// Define the function to fetch repository requests from the database.
# Description.
# + return - return value description
public isolated function getRepositoryRequests() returns RepositoryRequest[]|sql:Error {
    io:println(" - Running getRepositoryRequests() Function");
    // Execute the query and return a stream of RepositoryRequest records.
    stream<RepositoryRequest, sql:Error?> resultStream = dbClient->query(getRepositoryRequestsQuery());
    
    io:println("   - Result Stream: ", resultStream);
    
    RepositoryRequest[] repositoryRequests = [];
    check from  RepositoryRequest repositoryRequest in resultStream
        do {
            repositoryRequests.push(repositoryRequest);
        };
    return repositoryRequests;
}

// Insert a new repository request into the database.
# Description.
#
# + payload - parameter description
# + return - return value description
public isolated function insertRepositoryRequest(RepositoryRequestCreate payload) returns sql:ExecutionResult|sql:Error {
    io:println(" - Running insertRepositoryRequests() Function");
    return dbClient->execute(insertRepositoryRequestQuery(payload));
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
