// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import github_repo_manager.database as db;
import github_repo_manager.github as gh;

import ballerina/http;
import ballerina/log;
import ballerina/regex;

# Get the list of internal commiter teams in a GitHub organization.
#
# + organization - organization name
# + return - list of teams or error
public isolated function getTeams(string organization)
    returns string[]|error {

    string authToken = db:getPat(organization);
    http:Client githubClient = check gh:createGithubClient(authToken);
    string apiPath = string `/orgs/${organization}/teams`;
    http:Response|error response = githubClient->get(apiPath);
    if response is error {
        return response;
    }
    json jsonResponse = check response.getJsonPayload(); //TODO:make a record for this
    string[] teamList = [];
    if jsonResponse is json[] {
        foreach var team in jsonResponse {
            if team is map<json> {
                string teamName = team["name"].toString();
                if teamName.includes("-internal-commiters") {
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
public isolated function createGitHubRepository(db:RepositoryRequest repoRequest)
    returns gh:gitHubOperationResult[] {

    string repository = repoRequest.repoName;
    string organization = repoRequest.organization;
    string description = repoRequest.description;
    string repoTypeString = repoRequest.repoType;
    string enableIssuesString = repoRequest.enableIssues;
    string? websiteUrl = repoRequest.websiteUrl;
    string topicString = repoRequest.topics;
    string branchProtection = repoRequest.prProtection;
    string teamString = repoRequest.teams;
    string enableTriageWso2AllString = repoRequest.enableTriageWso2All;
    string enableTriageWso2AllInternsString = repoRequest.enableTriageWso2AllInterns;

    string[] teamList = regex:split(teamString, ",");
    string[] topicList = regex:split(topicString, ",");
    boolean isPrivate = repoTypeString == "public" ? false : true;
    boolean enableIssues = enableIssuesString == "Yes" ? true : false;
    boolean enableTriageWso2All = enableTriageWso2AllString == "Yes" ? true : false;
    boolean enableTriageWso2AllInterns = enableTriageWso2AllInternsString == "Yes" ? true : false;

    string authToken = db:getPat(organization);
    http:Client|error githubClient = gh:createGithubClient(authToken);
    if githubClient is error {
        log:printError("Error occurred while creating GitHub client");
        return [
            {
                operation: "createGitHubClient",
                status: "error",
                errorMessage: "Error occurred while creating GitHub client"
            }
        ];
    }

    gh:gitHubOperationResult[] gitopresults = [];

    gh:gitHubOperationResult createRepoResult = gh:createRepository(organization, repository, description, isPrivate, enableIssues, websiteUrl, githubClient);
    gitopresults.push(createRepoResult);
    if createRepoResult.status is "error" {
        log:printError("Error occurred while creating the repository");
        return gitopresults;
    }
    gh:gitHubOperationResult addTopicsResult = gh:addTopics(organization, repository, topicList, githubClient);
    gitopresults.push(addTopicsResult);

    gh:gitHubOperationResult[] labelError = gh:addLabels(organization, repository, githubClient);
    foreach gh:gitHubOperationResult labelErr in labelError {
        gitopresults.push(labelErr);
    }

    gh:gitHubOperationResult issueTemplateError = gh:addIssueTemplate(organization, repository, githubClient);
    gitopresults.push(issueTemplateError);

    gh:gitHubOperationResult issuePrTemplateError = gh:addPRTemplate(organization, repository, githubClient);
    gitopresults.push(issuePrTemplateError);

    gh:gitHubOperationResult branchProtectionError = gh:addBranchProtection(organization, repository, branchProtection, githubClient);
    gitopresults.push(branchProtectionError);

    gh:gitHubOperationResult[] teamError = gh:addTeams(organization, repository, teamList, enableTriageWso2All, enableTriageWso2AllInterns, githubClient);
    foreach gh:gitHubOperationResult teamErr in teamError {
        gitopresults.push(teamErr);
    }

    return gitopresults;
}

# returns a map of key-value pairs from the repository request object.
#
# + repoRequest - repository request object
# + return - key-value pairs
public isolated function createKeyValuePair(db:RepositoryRequest repoRequest)
    returns map<string> {

    map<string> keyValPairs = {
        "id": repoRequest.id.toString(),
        "email": repoRequest.email,
        "lead_email": repoRequest.leadEmail,
        "ccList": repoRequest.ccList,
        "requirement": repoRequest.requirement,
        "repoName": repoRequest.repoName,
        "organization": repoRequest.organization,
        "repoType": repoRequest.repoType,
        "description": repoRequest.description,
        "enableIssues": repoRequest.enableIssues.toString(),
        "websiteUrl": repoRequest.websiteUrl is string ? repoRequest.websiteUrl.toString() : "N/A",
        "topics": repoRequest.topics,
        "prProtection": repoRequest.prProtection,
        "teams": repoRequest.teams,
        "enableTriageWso2All": repoRequest.enableTriageWso2All,
        "enableTriageWso2AllInterns": repoRequest.enableTriageWso2AllInterns,
        "disableTriageReason": repoRequest.disableTriageReason,
        "cicdRequirement": repoRequest.cicdRequirement,
        "jenkinsJobType": repoRequest.jenkinsJobType is string ? repoRequest.jenkinsJobType.toString() : "N/A",
        "jenkinsGroupId": repoRequest.jenkinsGroupId is string ? repoRequest.jenkinsGroupId.toString() : "N/A",
        "azureDevopsOrg": repoRequest.azureDevopsOrg is string ? repoRequest.azureDevopsOrg.toString() : "N/A",
        "azureDevopsProject": repoRequest.azureDevopsProject is string ? repoRequest.azureDevopsProject.toString() : "N/A",
        "lead_comment": repoRequest.leadComment is string ? repoRequest.leadComment.toString() : "N/A",
        "timestamp": repoRequest.timestamp.toString()
    };
    return keyValPairs;
}

# Returns a keyvaluepair object containing the status of GitHub operations.
#
# + gh - github operation result array
# + return - keyvaluepair object
public isolated function getGhStatusReport(gh:gitHubOperationResult[] gh)
    returns map<string> {

    map<string> reportMap = {};
    foreach gh:gitHubOperationResult result in gh {
        string operation = result.operation;
        string status = result.status;
        reportMap[operation] = string `${status}`;
    }
    return reportMap;
}
