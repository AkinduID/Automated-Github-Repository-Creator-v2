// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/data.jsondata;
import ballerina/http;
import ballerina/io;
import ballerina/lang.array;

# Create a repository in GitHub and add requested parameters.
# 
# + input - Create repository input.
# + githubEntity - Github client
# + return - http response
public isolated function createRepository(CreateRepoInput input, http:Client githubEntity)
    returns gitHubOperationResult {
        
    io:println("Accessing createRepository() function");
    CreateRepoInput {orgName, repoName, autoInit, isPrivate, repoDescription, repoHomepage, 
    enableIssues, enableWiki, licenseTemplate, gitignoreTemplate} = input;
    json body = { 
        query: string `mutation {
            createGitRepository(input: {
                orgName: "${orgName}",
                repoName: "${repoName}",
                autoInit: ${autoInit},
                isPrivate: ${isPrivate},
                repoDescription: "${repoDescription}",
                repoHomepage: "${repoHomepage is string ? repoHomepage : ""}",
                enableIssues: ${enableIssues},
                enableWiki: ${enableWiki},
                licenseTemplate: "${licenseTemplate}",
                gitignoreTemplate: "${gitignoreTemplate}"
            }) {id}
        }`
    };
    http:Response|error response = githubEntity->/graphql.post(body);
    if response is error {
        return {
            operation: "Create Repository",
            status: "failure",
            errorMessage: response.message()
        };
    }
    return {
            operation: "Create Repository",
            status: "success",
            errorMessage: ()
    };
}

# API Call to add topics to a repository.
#
# + input - input object containing organization name, repository name, and list of topics
# + githubEntity - github client
# + return - http response
public isolated function addTopics(AddTopicsInput input, http:Client githubEntity) 
    returns gitHubOperationResult {

    io:println("Accessing addTopics() function");
    AddTopicsInput {orgName, repoName, topics} = input;
    string formattedTopics = formatGraphQLArray(topics);
    json body = {
        query: string `mutation {
            addTopics(input: {
                orgName: "${orgName}",
                repoName: "${repoName}",
                topics: ${formattedTopics}
            }) {names}
        }`
    };
    http:Response|error response = githubEntity->/graphql.post(body);
    if response is error {
        io:println("response error",response.toString());
        return {
            operation: "Add Topics",
            status: "failure",
            errorMessage: response.message()
        };
    }
    return {
        operation: "Add Topics",
        status: "success",
        errorMessage: ()
    };
}

# API Call to add labels to a repository.
#
# + organization - organization name
# + repository - repository name
# + githubEntity - github client
# + return - http response
public isolated function addLabels(string organization, string repository, http:Client githubEntity)
    returns gitHubOperationResult[] {

    io:println("Assessing addLabels() function");
    string filePath = resourcePath + "labels.json";
    json|error labelsJson = io:fileReadJson(filePath);
    if labelsJson is error {
        return [{
            operation: "Add Labels",
            status: "failure",
            errorMessage: labelsJson.message()
        }];
    }
    LabelData[]|error labelList = jsondata:parseAsType(labelsJson);
    if labelList is error {
        return [{
            operation: "Add Labels",
            status: "failure",
            errorMessage: labelList.message()
        }];
    }
    gitHubOperationResult[] responses = [];
    foreach LabelData label in labelList {
        json body = { 
            query: string `mutation {
                addLabel(input: {
                    orgName: "${organization}",
                    repoName: "${repository}",
                    labelName: "${label.name}",
                    labelColor: "${label.color}",
                    labelDescription: "${label.description}"
                }) {id}
            }`
        };
        http:Response|error response = githubEntity->/graphql.post(body);
        if response is error {
            responses.push({
                operation: string `Add Labels ${label.name}`,
                status: "failure",
                errorMessage: response.message()
            });
        }
        else{
            responses.push({
                operation: string `Add Labels ${label.name}`,
                status: "success",
                errorMessage: ()
            });
        }
    }
    return responses;
}

# API Call to add issue template to a repository.
#
# + organization - organization name  
# + repository - repository name 
# + githubEntity - github client
# + return - http response
public isolated function addIssueTemplate(string organization, string repository, http:Client githubEntity) 
    returns gitHubOperationResult {

    io:println("Accessing addIssueTemplate() function");
    string filePath = resourcePath + "issue_template.md";
    string|error issueTemplate = io:fileReadString(filePath);
    if issueTemplate is error {
        return {
            operation: "Add Issue Template",
            status: "failure",
            errorMessage: issueTemplate.message()
        };
    }
    string encodedIssueTemplate = array:toBase64(issueTemplate.toBytes());
    json payload = { 
        query: string `mutation {
            commitGitFile(input: {
                owner: "${organization}",
                repoName: "${repository}",
                path: "issue_template.md",
                message: "Add Issue Template",
                branch: "main",
                encodedContent: "${encodedIssueTemplate}"
            }) {content{url}}
        }`
    };
    http:Response|error response = githubEntity->/graphql.post(payload);
    if response is error {
        return {
            operation: "Add Issue Template",
            status: "failure",
            errorMessage: response.message()
        };
    }
    return {
        operation: "Add Issue Template",
        status: "success",
        errorMessage: ""
    };
}

# API Call to add pull request template to a repository.
#
# + organization - organization name
# + repository - repository name
# + githubEntity - github client
# + return - http response
public isolated function addPRTemplate(string organization, string repository, http:Client githubEntity)
    returns gitHubOperationResult {

    io:println("Accessing addPRTemplate() function");
    string filePath = resourcePath + "pull_request_template.md";
    string|error prTemplate = io:fileReadString(filePath);
    if prTemplate is error {
        return {
            operation: "Add Pull Request Template",
            status: "failure",
            errorMessage: prTemplate.message()
        };
    }
    string encodedPrTemplate = array:toBase64(prTemplate.toBytes());
    json payload = { 
        query: string `mutation {
            commitGitFile(input: {
                owner: "${organization}",
                repoName: "${repository}",
                path: "pull_request_template.md",
                message: "Add PR Template",
                branch: "main",
                encodedContent: "${encodedPrTemplate}"
            }) {content{url}}
        }`
    };
    http:Response|error response = githubEntity->/graphql.post(payload);
    if response is error {
        return {
            operation: "Add PR Template",
            status: "failure",
            errorMessage: response.message()
        };
    }
    return {
        operation: "Add PR Template",
        status: "success",
        errorMessage: ""
    };
}

# API Call to add branch protection to a repository.
#
# + input - input object containing organization name, repository name, and branch protection type
# + githubEntity - github client
# + return - http response
public isolated function addBranchProtection(AddBranchProtectionInput input, http:Client githubEntity)
    returns gitHubOperationResult{

    io:println("Accessing addBranchProtection() function");
    AddBranchProtectionInput {orgName, repoName, branchProtection} = input;
    json payload = {
        query: string `mutation {
            addBranchProtection(input: {
                orgName: "${orgName}",
                repoName: "${repoName}",
                branchProtectionType: "${branchProtection}",
            }) {url}
        }`
    };
    http:Response|error response = githubEntity->/graphql.post(payload);
    if response is error {
        return {
            operation: "Add Branch Protection",
            status: "failure",
            errorMessage: response.message()
        };
    }
    return {
        operation: "Add Branch Protection",
        status: "success",
        errorMessage: ""
    };
}

# API Call to add teams to a repository.
#
# + input - input object containing organization name, repository name, and list of teams
# + githubEntity - github client
# + return - http response
public isolated function addTeams(AddTeamInput input, http:Client githubEntity) 
    returns gitHubOperationResult[] {

    io:println("Accessing addTeams() function");
    AddTeamInput {orgName, repoName, teams, enable_triage_wso2all, enable_triage_wso2allinterns} = input;
    http:Response|error response;
    gitHubOperationResult[] responses = [];
    string[] updatedTeams = addDefaultTeams(orgName, teams);
    string permission;
    foreach string team in updatedTeams {
        if team.includes("infra") || team.includes("-commiters") {
            permission = "push";
        }
        else if orgName == "wso2-enterprise" && 
            ((team.includes("gitopslab-all") && enable_triage_wso2all)||
                (team.includes("gitopslab-all-interns") && enable_triage_wso2allinterns)) {
                    permission = "triage";
        } 
        else if orgName != "wso2-enterprise" &&
            (team.includes("gitopslab-all") || team.includes("gitopslab-all-interns")) {
                permission = "triage";
        } 
        else {
            permission = "pull";
        }
        json payload = {
            query: string `mutation {
                addTeamToRepository(input: {
                    orgName: "${orgName}",
                    repoName: "${repoName}",
                    teamSlug: "${team}",
                    teamPermission: "${permission}"
                }) {status}
            }`
        };
        response = githubEntity->/graphql.post(payload);
        if response is error {
            responses.push({
                operation: string `Add Teams ${team}`,
                status: "failure",
                errorMessage: response.message()
            });
        }
        else{
            responses.push({
                operation: string `Add Teams ${team}`,
                status: "success",
                errorMessage: ""
            });
        }
    }
    return responses;
}
