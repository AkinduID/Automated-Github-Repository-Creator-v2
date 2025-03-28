import ballerina/io;
import ballerina/http;
import ballerina/lang.array;
import ballerina/data.jsondata;

# API Call to create a new repository in GitHub.
# 
# + organization - Organization name
# + repoName - repository name 
# + repoDesc - repository description  
# + isPrivate - repository type (false - public/ true - private) 
# + enableIssues - enable issues  
# + websiteUrl - website URL (optional)  
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function createRepository(string organization, string repoName, string repoDesc, boolean isPrivate, boolean enableIssues, string? websiteUrl, http:Client githubClient) 
returns error|null {
    io:println("Accessing createRepository() function");
    json body = {
        name: repoName,
        'private: isPrivate,
        description: repoDesc,
        homepage: websiteUrl, // optional
        has_issues: enableIssues,
        // default values
        "has_wiki": false,
        "auto_init": true,
        "gitignore_template": "Java",
        "license_template": "apache-2.0"
    };
    string apiPath = string `/orgs/${organization}/repos`;
    http:Response response = check githubClient->post(apiPath, body);
    io:println("Response status code: ", response.statusCode);
    io:println("Response: ", response.getJsonPayload());
    io:println("-----------------------------------------------------------------------");
}

# API Call to add topics to a repository.
# 
# + organization - organization name  
# + repository - repository name 
# + topicList - list of topics to be added  
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addTopics(string organization, string repository, string[] topicList, http:Client githubClient) 
returns error|null {
    io:println("Accessing addTopics() function");
    json body = {
        names: topicList
    };
    string apiPath = string `/repos/${organization}/${repository}/topics`;
    http:Response response = check githubClient->put(apiPath, body);
    io:println("Response status code: ", response.statusCode);
    io:println("Response: ", response.getJsonPayload());
    io:println("-----------------------------------------------------------------------");
}


# API Call to add labels to a repository.
# 
# + organization - organization name
# + repository - repository name
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addLabels(string organization, string repository, http:Client githubClient) 
returns error|null {
    string filePath = "resources/github_resources/labels.json";
    json labelsJson = check io:fileReadJson(filePath);
    io:println("Labels JSON: ", labelsJson);
    LabelData[] labelList = check jsondata:parseAsType(labelsJson);
    string apiPath = string `/repos/${organization}/${repository}/labels`;
    http:Response[] responses = [];
    if labelsJson is json[] {
        foreach LabelData label in labelList {
            json body = {
                name: label.name,
                color: label.color,
                description: label.description
            };
            http:Response response = check githubClient->post(apiPath,body);
            responses.push(response);
            io:println("Response status code: ", response.statusCode);
            io:println("Response: ", response.getJsonPayload());
            io:println("-----------------------------------------------------------------------");
        }
    }
}


# API Call to add issue template to a repository.
# 
# + organization - organization name  
# + repository - repository name 
# + githubClient - GitHub Personal Access Token 
# + return - http response
public function addIssueTemplate(string organization, string repository, http:Client githubClient) 
returns error|null {
    io:println("Accessing addIssueTemplate() function");
    string filePath = "resources/github_resources/issue_template.md";
    string issueTemplate = check io:fileReadString(filePath);
    string encodedIssueTemplate = array:toBase64(issueTemplate .toBytes());

    json payload = {
        message: "Add Issue Template",
        content: encodedIssueTemplate,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/issue_template.md`;
    http:Response response = check githubClient->put(apiPath, payload);
    io:println("Response status code: ", response.statusCode);
    io:println("Response: ", response.getJsonPayload());
    io:println("-----------------------------------------------------------------------");
}

# API Call to add pull request template to a repository.
# 
# + organization - organization name
# + repository - repository name
# + githubClient - GitHub Personal Access Token 
# + return - http response
public function addPRTemplate(string organization, string repository, http:Client githubClient) 
returns error|null {
    io:println("Accessing addPRTemplate() function");
    string filePath = "resources/github_resources/pull_request_template.md";
    string prTemplate = check io:fileReadString(filePath);
    string encodedPrTemplate = array:toBase64(prTemplate .toBytes());

    json payload = {
        message: "Add PR Template",
        content: encodedPrTemplate,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/pull_request_template.md`;
    http:Response response = check githubClient->put(apiPath, payload);
    io:println("Response status code: ", response.statusCode);
    io:println("Response: ", response.getJsonPayload());
    io:println("-----------------------------------------------------------------------");
}

# API Call to add branch protection to a repository.
# 
# + organization - organization name 
# + repository - repository name 
# + branch_protection - branch protection type (Default/Bal)
# + githubClient - GitHub Personal Access Token
# + return - http response
public isolated function addBranchProtection(string organization, string repository, string branch_protection, http:Client githubClient) 
returns error|null {
    io:println("Accessing addBranchProtection() function");
    json payload;
    http:Response response;
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
    else{
        payload = {
            "has_issues": false,
            "has_projects": false
        };
        apiPath = string `/repos/${organization}/${repository}`;
    }
    response = check githubClient->put(apiPath, payload);
    io:println("Response: ", response.getJsonPayload());
    io:println("Response status code: ", response.statusCode);
    io:println("-----------------------------------------------------------------------");
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
public isolated function addTeams(string organization, string repository, string[] teams, boolean enable_triage_wso2all,boolean enable_triage_wso2allinterns,http:Client githubClient) 
returns error|null {
    io:println("Accessing addTeams() function");
    json payload;
    string apiPath;
    http:Response response;
    http:Response[] responses = [];
    string[] updatedTeams = addDefaultTeams(organization, teams);
    foreach string team in updatedTeams {
        apiPath = string `/orgs/${organization}/teams/${team}/repos/${organization}/${repository}`;
        if team.includes("infra") || team.includes("-commiters"){
            payload = {
                "permission": "push"
            };
        }
        else if organization == "wso2-enterprise" && ((team.includes("gitopslab-all") && enable_triage_wso2all) || (team.includes("gitopslab-all-interns") && enable_triage_wso2allinterns)) {
            payload = {
                "permission": "triage"
            };
        }
        else if (team.includes("gitopslab-all") && enable_triage_wso2all) || (team.includes("gitopslab-all-interns") && enable_triage_wso2allinterns) {
            payload = {
                "permission": "triage"
            };
        }
        else{
            payload = {
                "permission": "pull"
            };
        }
        response = check githubClient->put(apiPath, payload);
        io:println("Team - ", team, "Response status code: ", response.statusCode);
        io:println("Response: ", response);
        io:println("------------------------------------------------------------------------------");
        responses.push(response);
    }
}