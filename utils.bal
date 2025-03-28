import ballerina/http;
import ballerina_crud_application.database as db;
import ballerina_crud_application.github as gh;
import ballerina_crud_application.email;
import ballerina/regex;

# Get the list of internal commiter teams in a GitHub organization.
# 
# + organization - organization name
# + return - list of teams or error
public function getTeams(string organization) 
returns string[]|error {
    string authToken = db:getPat(organization);
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
public function createGitHubRepository(db:RepositoryRequest repoRequest) 
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

    string authToken = db:getPat(organization);
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });

    check gh:createRepository(organization, repository, description, isPrivate, enableIssues, websiteUrl, githubClient);
    error[] errors = [];
    error? topicError =  gh:addTopics(organization, repository, topicList, githubClient);
    error? labelError = gh:addLabels(organization, repository, githubClient);
    error? issueTemplateError =  gh:addIssueTemplate(organization, repository, githubClient);
    error? issuePrTemplateError = gh:addPRTemplate(organization, repository, githubClient);
    error? branchProtectionError = gh:addBranchProtection(organization, repository, branchProtection, githubClient);
    error? teamError = gh:addTeams(organization, repository, teamList, enableTriageWso2All, enableTriageWso2AllInterns, githubClient);
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

# Convert a repository request object to an email object.
#
# + repoRequest - repository request object
# + return - email:Request object
public function convertToEmailObject(db:RepositoryRequest repoRequest)
returns email:Request{
    email:Request request = {
        id: repoRequest.id,
        email: repoRequest.email,
        lead_email: repoRequest.lead_email,
        requirement: repoRequest.requirement,
        ccList: repoRequest.ccList,
        repoName: repoRequest.repoName,
        organization: repoRequest.organization,
        repoType: repoRequest.repoType,
        description: repoRequest.description,
        enableIssues: repoRequest.enableIssues,
        websiteUrl: repoRequest.websiteUrl,
        topics: repoRequest.topics,
        prProtection: repoRequest.prProtection,
        teams: repoRequest.teams,
        enableTriageWso2All: repoRequest.enableTriageWso2All,
        enableTriageWso2AllInterns: repoRequest.enableTriageWso2AllInterns,
        disableTriageReason: repoRequest.disableTriageReason,
        cicdRequirement: repoRequest.cicdRequirement,
        jenkinsJobType: repoRequest.jenkinsJobType,
        jenkinsGroupId: repoRequest.jenkinsGroupId,
        azureDevopsOrg: repoRequest.azureDevopsOrg,
        azureDevopsProject: repoRequest.azureDevopsProject,
        comments: repoRequest.comments,
        timestamp: repoRequest.timestamp
    };
    return request;
}

// public function convertToCreateRequestEmailObject(db:RepositoryRequest repoRequest) 
// returns email:createRequest{
//     email:createRequest request = {
//         id: repoRequest.id,
//         email: repoRequest.email,
//         lead_email: repoRequest.lead_email,
//         requirement: repoRequest.requirement,
//         ccList: repoRequest.ccList,
//         repoName: repoRequest.repoName,
//         organization: repoRequest.organization,
//         repoType: repoRequest.repoType,
//         description: repoRequest.description,
//         enableIssues: repoRequest.enableIssues,
//         websiteUrl: repoRequest.websiteUrl,
//         topics: repoRequest.topics,
//         prProtection: repoRequest.prProtection,
//         teams: repoRequest.teams,
//         enableTriageWso2All: repoRequest.enableTriageWso2All,
//         enableTriageWso2AllInterns: repoRequest.enableTriageWso2AllInterns,
//         disableTriageReason: repoRequest.disableTriageReason,
//         cicdRequirement: repoRequest.cicdRequirement,
//         jenkinsJobType: repoRequest.jenkinsJobType,
//         jenkinsGroupId: repoRequest.jenkinsGroupId,
//         azureDevopsOrg: repoRequest.azureDevopsOrg,
//         azureDevopsProject: repoRequest.azureDevopsProject,
//         timestamp: repoRequest.timestamp
//     };
//     return request;
// }

// public function convertToUpdateRequestEmailObject(db:RepositoryRequest oldRequest, db:RepositoryRequest newRequest)
//     returns email:updateRequest {
//     email:updateRequest request = {
//         id: newRequest.id,
//         email: newRequest.email,
//         lead_email: newRequest.lead_email,
//         requirement: newRequest.requirement,
//         ccList: newRequest.ccList,
//         repoName: [oldRequest.repoName, newRequest.repoName],
//         organization: [oldRequest.organization, newRequest.organization],
//         repoType: [oldRequest.repoType, newRequest.repoType],
//         description: [oldRequest.description, newRequest.description],
//         enableIssues: [oldRequest.enableIssues, newRequest.enableIssues],
//         websiteUrl: [oldRequest.websiteUrl, newRequest.websiteUrl],
//         topics: [oldRequest.topics, newRequest.topics],
//         prProtection: [oldRequest.prProtection, newRequest.prProtection],
//         teams: [oldRequest.teams, newRequest.teams],
//         enableTriageWso2All: [oldRequest.enableTriageWso2All, newRequest.enableTriageWso2All],
//         enableTriageWso2AllInterns: [oldRequest.enableTriageWso2AllInterns, newRequest.enableTriageWso2AllInterns],
//         disableTriageReason: [oldRequest.disableTriageReason, newRequest.disableTriageReason],
//         cicdRequirement: [oldRequest.cicdRequirement, newRequest.cicdRequirement],
//         jenkinsJobType: [oldRequest.jenkinsJobType, newRequest.jenkinsJobType],
//         jenkinsGroupId: [oldRequest.jenkinsGroupId, newRequest.jenkinsGroupId],
//         azureDevopsOrg: [oldRequest.azureDevopsOrg, newRequest.azureDevopsOrg],
//         azureDevopsProject: [oldRequest.azureDevopsProject, newRequest.azureDevopsProject]
//     };
//     return request;
// }

// public function convertToCommentRequestEmailObject(db:RepositoryRequest repoRequest)
//     returns email:commentRequest{
//     email:commentRequest request = {
//         id: repoRequest.id,
//         email: repoRequest.email,
//         lead_email: repoRequest.lead_email,
//         ccList: repoRequest.ccList,
//         comments: repoRequest.comments
//     };
//     return request;
// }

// public function convertToApproveRequestEmailObject(db:RepositoryRequest repoRequest)
//     returns email:approveRequest{
//     email:approveRequest request = {
//         id: repoRequest.id,
//         email: repoRequest.email,
//         lead_email: repoRequest.lead_email,
//         ccList: repoRequest.ccList,
//         repoName: repoRequest.repoName,
//         organization: repoRequest.organization
//     };
//     return request;
// }