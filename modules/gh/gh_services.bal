import ballerina/http;
import ballerina_crud_application.database;
import ballerina/regex;
import ballerina/io;

# Description.
# create a new GitHub repository
# + repoRequest - repository request object
# + return - http:Response or error
public function createGitHubRepository(database:RepositoryRequest repoRequest) returns 
http:Response|error {

    // http:Response []|error[] ghServiceResponses;
    
    string repository = repoRequest.repoName;
    string organization = repoRequest.organization;
    string description = repoRequest.description;
    string repoTypeString = repoRequest.repoType;
    boolean enableIssues = repoRequest.enableIssues;
    string? websiteUrl = repoRequest.websiteUrl;
    string topicString = repoRequest.topics;
    string branchProtection = repoRequest.prProtection;
    string teamString = repoRequest.teams;
    boolean enable_triage_wso2all = repoRequest.enableTriageWso2All;
    boolean enable_triage_wso2allinterns = repoRequest.enableTriageWso2AllInterns;

    string[] teamList = regex:split(teamString, ",");
    string[] topicList = regex:split(topicString, ",");
    boolean isPrivate = repoTypeString == "public" ? false : true;

    string authToken = database:getPat(organization);

    http:Response|error repoCreationResponse = createRepository(organization, repository, description, isPrivate, enableIssues, websiteUrl, authToken);
    // if repoCreationResponse is error{
    //     return <http:InternalServerError>{
    //         body:"Error in Creating Repository"+ repoCreationResponse.toString();
    //     }
    // }
    http:Response|error addTopicsResponse = addTopics(organization, repository, topicList, authToken);
    // ghServiceResponses.push(addTopicsResponse);
    http:Response[]|error addLabelsResponse = addLabels(organization, repository, authToken);
    // ghServiceResponses.push(addLabelsResponse);
    http:Response|error addIssueTemplateResponse = addIssueTemplate(organization, repository, authToken);
    // ghServiceResponses.push(addIssueTemplateResponse);
    http:Response|error addPRTemplateResponse = addPRTemplate(organization, repository, authToken);
    // ghServiceResponses.push(addPRTemplateResponse);
    http:Response|error branchProtectionResponse = addBranchProtection(organization, repository, branchProtection, authToken);
    // ghServiceResponses.push(branchProtectionResponse);
    http:Response[]|error addTeamsResponse = addTeams(organization, repository, teamList, enable_triage_wso2all, enable_triage_wso2allinterns, authToken);
    // ghServiceResponses.push(addTeamsResponse);
    io:println(repoCreationResponse, addTopicsResponse, addLabelsResponse, addIssueTemplateResponse, addPRTemplateResponse, branchProtectionResponse, addTeamsResponse);

    return repoCreationResponse; // Returning the first response. You might need to handle responses differently.
}