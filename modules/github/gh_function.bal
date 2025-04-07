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

# API Call to create a new repository in GitHub.
#
# + organization - Organization name
# + repoName - repository name 
# + repoDesc - repository description  
# + isPrivate - repository type (false - public/ true - private) 
# + enableIssues - enable issues  
# + websiteUrl - website URL (optional)  
# + githubClient - GitHub Client Object
# + return - http response
public isolated function createRepository(string organization, string repoName, string repoDesc, boolean isPrivate, boolean enableIssues, string? websiteUrl, http:Client githubClient)
    returns gitHubOperationResult {

    io:println("Accessing createRepository() function");
    json body = {
        name: repoName,
        'private: isPrivate,
        description: repoDesc,
        homepage: websiteUrl, // optional
        has_issues: enableIssues,
        has_wiki: false,
        auto_init: true,
        gitignore_template: "Java",
        license_template: "apache-2.0"
    };
    string apiPath = string `/orgs/${organization}/repos`;
    http:Response|error response = githubClient->post(apiPath, body);
     if response is error {
        return {
            operation: "Create Repository",
            status: "failure",
            errorMessage: response.message()
        };
    }
    io:println("Response status code: ", response.statusCode);
    return {
        operation: "Create Repository",
        status: "success",
        errorMessage: ()
    };
}

# API Call to add topics to a repository.
#
# + organization - organization name  
# + repository - repository name 
# + topicList - list of topics to be added  
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addTopics(string organization, string repository, string[] topicList, http:Client githubClient)
    returns gitHubOperationResult {

    io:println("Accessing addTopics() function");
    json body = {
        names: topicList
    };
    string apiPath = string `/repos/${organization}/${repository}/topics`;
    http:Response|error response = githubClient->put(apiPath, body);
    if response is error {
        return {
            operation: "Add Topics",
            status: "failure",
            errorMessage: response.message()
        };
    }
    io:println("Response status code: ", response.statusCode);
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
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addLabels(string organization, string repository, http:Client githubClient)
    returns gitHubOperationResult[] {

    string filePath = resourcePath + "labels.json";
    json|error labelsJson = io:fileReadJson(filePath);
    if labelsJson is error {
        return [{
            operation: "Add Labels",
            status: "failure",
            errorMessage: labelsJson.message()
        }];
    }
    io:println("Labels JSON: ", labelsJson);
    LabelData[]|error labelList = jsondata:parseAsType(labelsJson);
    if labelList is error {
        return [{
            operation: "Add Labels",
            status: "failure",
            errorMessage: labelList.message()
        }];
    }
    string apiPath = string `/repos/${organization}/${repository}/labels`;
    gitHubOperationResult[] responses = [];
    // if labelsJson is json[] {
    foreach LabelData label in labelList {
        json body = {
            name: label.name,
            color: label.color,
            description: label.description
        };
        http:Response|error response = githubClient->post(apiPath, body);
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
# + githubClient - GitHub Personal Access Token 
# + return - http response
public isolated function addIssueTemplate(string organization, string repository, http:Client githubClient)
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
        message: "Add Issue Template",
        content: encodedIssueTemplate,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/issue_template.md`;
    http:Response|error response = githubClient->put(apiPath, payload);
    if response is error {
        return {
            operation: "Add Issue Template",
            status: "failure",
            errorMessage: response.message()
        };
    }
    io:println("Response status code: ", response.statusCode);
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
# + githubClient - GitHub Personal Access Token 
# + return - http response
public isolated function addPRTemplate(string organization, string repository, http:Client githubClient)
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
        message: "Add Pull Request Template",
        content: encodedPrTemplate,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/pull_request_template.md`;
    http:Response|error response = githubClient->put(apiPath, payload);
    if response is error {
        return {
            operation: "Add PR Template",
            status: "failure",
            errorMessage: response.message()
        };
    }
    io:println("Response status code: ", response.statusCode);
    return {
        operation: "Add PR Template",
        status: "success",
        errorMessage: ""
    };
}

# API Call to add branch protection to a repository.
#
# + organization - organization name 
# + repository - repository name 
# + branch_protection - branch protection type (Default/Bal)
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addBranchProtection(string organization, string repository, string branch_protection, http:Client githubClient)
    returns gitHubOperationResult{

    io:println("Accessing addBranchProtection() function");
    json payload;
    string apiPath;
    if branch_protection == "Default" {
        payload = {
            "required_status_checks": null,
            "enforce_admins": null,
            "required_pull_request_reviews": {
                "include_admins": false
            },
            "restrictions": null
        };
        apiPath = string `/repos/${organization}/${repository}/branches/main/protection`;
    }
    else {
        payload = {
            "has_issues": false,
            "has_projects": false
        };
        apiPath = string `/repos/${organization}/${repository}`;
    }
    http:Response|error response = githubClient->put(apiPath, payload);
    if response is error {
        return {
            operation: "Add Issue Template",
            status: "failure",
            errorMessage: response.message()
        };
    }
    io:println("Response status code: ", response.statusCode);
    return {
        operation: "Add Issue Template",
        status: "success",
        errorMessage: ""
    };
}

# API Call to add teams to a repository.
#
# + organization - organization name  
# + repository - repository name 
# + teams - list of teams to be added 
# + enable_triage_wso2all - enable triage for wso2all team 
# + enable_triage_wso2allinterns - enable triage for wso2allinterns team
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addTeams(string organization, string repository, string[] teams, boolean enable_triage_wso2all, boolean enable_triage_wso2allinterns, http:Client githubClient)
    returns gitHubOperationResult[] {

    io:println("Accessing addTeams() function");
    json payload;
    string apiPath;
    http:Response|error response;
    gitHubOperationResult[] responses = [];
    string[] updatedTeams = addDefaultTeams(organization, teams);

    foreach string team in updatedTeams {
        apiPath = string `/orgs/${organization}/teams/${team}/repos/${organization}/${repository}`;
        if team.includes("infra") || team.includes("-commiters") {
            payload = {
                "permission": "push"
            };
        } else if organization == "wso2-enterprise" &&
                ((team.includes("gitopslab-all") && enable_triage_wso2all) ||
                    (team.includes("gitopslab-all-interns") && enable_triage_wso2allinterns)) {
            payload = {
                "permission": "triage"
            };
        } else if organization != "wso2-enterprise" &&
                (team.includes("gitopslab-all") || team.includes("gitopslab-all-interns")) {
            payload = {
                "permission": "triage"
            };
        } else {
            payload = {
                "permission": "pull"
            };
        }
        response = githubClient->put(apiPath, payload);
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
