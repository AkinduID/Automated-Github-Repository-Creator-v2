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


# Create a new GitHub repository.
# 
# + repoRequest - repository request object
# + return - http:Response or error
public function createGitHubRepository(database:RepositoryRequest repoRequest) 
returns error|null {
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
    check gh:addTopics(organization, repository, topicList, authToken);
    check gh:addLabels(organization, repository, authToken);
    check gh:addIssueTemplate(organization, repository, authToken);
    check gh:addPRTemplate(organization, repository, authToken);
    check gh:addBranchProtection(organization, repository, branchProtection, authToken);
    check gh:addTeams(organization, repository, teamList, enableTriageWso2All, enableTriageWso2AllInterns, authToken);
}