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
    returns error|error[]|null { //TODO: error array remove

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
    http:Client githubClient = check gh:createGithubClient(authToken);

    check gh:createRepository(organization, repository, description, isPrivate, enableIssues, websiteUrl, githubClient);
    error[] errors = [];
    // TODO: create object for success or failure
    error? topicError = gh:addTopics(organization, repository, topicList, githubClient);
    error? labelError = gh:addLabels(organization, repository, githubClient);
    error? issueTemplateError = gh:addIssueTemplate(organization, repository, githubClient);
    error? issuePrTemplateError = gh:addPRTemplate(organization, repository, githubClient);
    error? branchProtectionError = gh:addBranchProtection(organization, repository, branchProtection, githubClient);
    error? teamError = gh:addTeams(organization, repository, teamList, enableTriageWso2All, enableTriageWso2AllInterns, githubClient);
    if topicError is error {
        log:printError("Error occurred while adding topics to the repository", topicError);
        errors.push(topicError);
    }
    if labelError is error {
        log:printError("Error occurred while adding labels to the repository", labelError);
        errors.push(labelError);
    }
    if issueTemplateError is error {
        log:printError("Error occurred while adding issue template to the repository", issueTemplateError);
        errors.push(issueTemplateError);
    }
    if issuePrTemplateError is error {
        log:printError("Error occurred while adding PR template to the repository", issuePrTemplateError);
        errors.push(issuePrTemplateError);
    }
    if branchProtectionError is error {
        log:printError("Error occurred while adding branch protection to the repository", branchProtectionError);
        errors.push(branchProtectionError);
    }
    if teamError is error {
        log:printError("Error occurred while adding teams to the repository", teamError);
        errors.push(teamError);
    }

    return errors.length() > 0 ? errors : null;
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
        "comment": repoRequest.comment is string ? repoRequest.comment.toString() : "N/A",
        "timestamp": repoRequest.timestamp.toString()
    };
    return keyValPairs;
}
