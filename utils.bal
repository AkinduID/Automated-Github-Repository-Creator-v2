// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import github_repo_manager.database as db;
import github_repo_manager.github as gh;
// import github_repo_manager.email;
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

public function createKeyValuePair(db:RepositoryRequest repoRequest) returns map<string> {
    map<string> keyValPairs = {
        "id": repoRequest.id.toString(),
        "email": repoRequest.email,
        "lead_email": repoRequest.lead_email,
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
        "enableTriageWso2All": repoRequest.enableTriageWso2All.toString(),
        "enableTriageWso2AllInterns": repoRequest.enableTriageWso2AllInterns.toString(),
        "disableTriageReason": repoRequest.disableTriageReason is string ? repoRequest.disableTriageReason.toString() : "N/A",
        "cicdRequirement": repoRequest.cicdRequirement,
        "jenkinsJobType": repoRequest.jenkinsJobType is string ? repoRequest.jenkinsJobType.toString() : "N/A",
        "jenkinsGroupId": repoRequest.jenkinsGroupId is string ? repoRequest.jenkinsGroupId.toString() : "N/A",
        "azureDevopsOrg": repoRequest.azureDevopsOrg is string ? repoRequest.azureDevopsOrg.toString() : "N/A",
        "azureDevopsProject": repoRequest.azureDevopsProject is string ? repoRequest.azureDevopsProject.toString() : "N/A",
        "comments": repoRequest.comments is string ? repoRequest.comments.toString() : "N/A",
        "timestamp": repoRequest.timestamp.toString()
    };
    return keyValPairs;
}