import ballerina/http;
import ballerina_crud_application.database;
import ballerina_crud_application.github as gh;
import ballerina/regex;

# Get the list of internal commiter teams in a GitHub organization.
# 
# + organization - organization name
# + return - list of teams or error
public function getTeams(string organization) 
returns string[]|error {
    string authToken = database:getPat(organization);
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
    string apiPath = string `/orgs/${organization}/teams`;
    http:Response|error response = githubClient->get(apiPath);
    if response is error {
        return response;
    }
    json jsonResponse = check response.getJsonPayload();
    string[] teamList = [];
    if jsonResponse is json[] {
        foreach var team in jsonResponse {
            if team is map<json> {
                string teamName = team["name"].toString();
                if teamName.includes("-internal-commiters"){
                    teamList.push(teamName);
                }
            }
        }
    }
    return teamList;
}


# Create a new GitHub repository and add requested parameters.
#  
# + repoRequest - repository request object
# + return - http:Response or error
public function createGitHubRepository(database:RepositoryRequest repoRequest) 
returns error|error[]|null {
    string repository = repoRequest.repoName;
    string organization = repoRequest.organization;
    string description = repoRequest.description;
    string repoTypeString = repoRequest.repoType;
    boolean enableIssues = repoRequest.enableIssues;
    string? websiteUrl = repoRequest.websiteUrl;
    string topicString = repoRequest.topics;
    string branchProtection = repoRequest.prProtection;
    string teamString = repoRequest.teams;
    boolean enableTriageWso2All = repoRequest.enableTriageWso2All;
    boolean enableTriageWso2AllInterns = repoRequest.enableTriageWso2AllInterns;

    string[] teamList = regex:split(teamString, ",");
    string[] topicList = regex:split(topicString, ",");
    boolean isPrivate = repoTypeString == "public" ? false : true;

    string authToken = database:getPat(organization);

    check gh:createRepository(organization, repository, description, isPrivate, enableIssues, websiteUrl, authToken);
    error[] errors = [];
    error? topicError =  gh:addTopics(organization, repository, topicList, authToken);
    error? labelError = gh:addLabels(organization, repository, authToken);
    error? issueTemplateError =  gh:addIssueTemplate(organization, repository, authToken);
    error? issuePrTemplateError = gh:addPRTemplate(organization, repository, authToken);
    error? branchProtectionError = gh:addBranchProtection(organization, repository, branchProtection, authToken);
    error? teamError = gh:addTeams(organization, repository, teamList, enableTriageWso2All, enableTriageWso2AllInterns, authToken);
    if topicError is error {
        errors.push(topicError);
    }
    if labelError is error {
        errors.push(labelError);
    }
    if issueTemplateError is error {
        errors.push(issueTemplateError);
    }
    if issuePrTemplateError is error {
        errors.push(issuePrTemplateError);
    }
    if branchProtectionError is error {
        errors.push(branchProtectionError);
    }
    if teamError is error {
        errors.push(teamError);
    }

    return errors.length() > 0 ? errors : null;
}