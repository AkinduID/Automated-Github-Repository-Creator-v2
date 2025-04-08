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
public isolated function getTeams(string organization) returns string[]|error {
    log:printInfo("Accessing getTeams() function");
    http:Client githubClient = check gh:createGithubClient();
    json payload = {
        query: string `query {
            githubTeams(orgName: "${organization}") {
                slug
            }
        }`
    };
    http:Response|error response = githubClient->/graphql.post(payload);
    if response is error {
        log:printError("Error occurred while fetching teams", response);
        return response;
    }
    json jsonResponse = check response.getJsonPayload();
    log:printInfo("Response received from GitHub API: "+ jsonResponse.toJsonString());
    gh:GitHubTeamsResponse teamsResponse = check jsonResponse.cloneWithType(gh:GitHubTeamsResponse);
    string[] teamList = [];
    foreach var team in teamsResponse.data.githubTeams {
        if team.slug.includes("-internal-commiters") {
            teamList.push(team.slug);
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

    http:Client|error githubEntity = gh:createGithubClient();
    if githubEntity is error {
        return [{
            operation: "createGitHubClient",
            status: "failure",
            errorMessage: githubEntity.message()
        }];
    }
    gh:gitHubOperationResult[] gitopresults = [];
    string orgName = repoRequest.organization;
    string repoName = repoRequest.repoName;
    gh:CreateRepoInput createRepoInput = {
        orgName: repoRequest.organization,
        repoName: repoRequest.repoName,
        autoInit: true,
        isPrivate: repoRequest.repoType == "public" ? false : true,
        repoDescription: repoRequest.description,
        repoHomepage: repoRequest.websiteUrl,
        enableIssues: repoRequest.enableIssues == "Yes" ? true : false
    };
    gh:AddTopicsInput addTopicsInput = {
        orgName: repoRequest.organization,
        repoName: repoRequest.repoName,
        topics: regex:split(repoRequest.topics, ",")
    };

    gh:AddTeamInput addTeamInput = {
        orgName: repoRequest.organization,
        repoName: repoRequest.repoName,
        teams: regex:split(repoRequest.teams, ","),
        enable_triage_wso2all: repoRequest.enableTriageWso2All == "Yes" ? true : false,
        enable_triage_wso2allinterns: repoRequest.enableTriageWso2AllInterns == "Yes" ? true : false
    };

    gh:AddBranchProtectionInput addBranchProtectionInput = {
        orgName: repoRequest.organization,
        repoName: repoRequest.repoName,
        branchProtection: repoRequest.prProtection
    };

    gh:gitHubOperationResult createRepoResult = gh:createRepository(createRepoInput,githubEntity);
    gitopresults.push(createRepoResult);
    if createRepoResult.status is "error" {
        log:printError("Error occurred while creating the repository");
        return gitopresults;
    }
    gh:gitHubOperationResult addTopicsResult = gh:addTopics(addTopicsInput,githubEntity);
    gitopresults.push(addTopicsResult);

    gh:gitHubOperationResult[] labelError = gh:addLabels(orgName, repoName, githubEntity);
    foreach gh:gitHubOperationResult labelErr in labelError {
        gitopresults.push(labelErr);
    }

    gh:gitHubOperationResult issueTemplateError = gh:addIssueTemplate(orgName, repoName, githubEntity);
    gitopresults.push(issueTemplateError);

    gh:gitHubOperationResult issuePrTemplateError = gh:addPRTemplate(orgName, repoName, githubEntity);
    gitopresults.push(issuePrTemplateError);

    gh:gitHubOperationResult branchProtectionError = gh:addBranchProtection(addBranchProtectionInput, githubEntity);
    gitopresults.push(branchProtectionError);

    gh:gitHubOperationResult[] teamError = gh:addTeams(addTeamInput,githubEntity);
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
