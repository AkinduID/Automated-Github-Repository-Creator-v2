import ballerina/io;
import ballerina/http;
import ballerina/lang.array;

# API Call to create a new repository in GitHub.
# 
# + organization - Organization name
# + repoName - repository name 
# + repoDesc - repository description  
# + isPrivate - repository type (false - public/ true - private) 
# + enableIssues - enable issues  
# + websiteUrl - website URL (optional)  
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function createRepository(string organization, string repoName, string repoDesc, boolean isPrivate, boolean enableIssues, string? websiteUrl, string authToken) 
returns error|null {
    io:println("Accessing createRepository() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
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
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addTopics(string organization, string repository, string[] topicList, string authToken) 
returns error|null {
    io:println("Accessing addTopics() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
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
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addLabels(string organization, string repository, string authToken) 
returns error|null {
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
    LabelData[] labelsList = [
        { name: "Type/Bug", color: "1d76db", description: "Identifies a bug in the project" },
        { name: "Type/New Feature", color: "1d76db", description: "Represents a request or task for a new feature" },
        { name: "Type/Epic", color: "1d76db", description: "Denotes an epic, which is a large body of work that encompasses multiple tasks" },
        { name: "Type/Improvement", color: "1d76db", description: "Marks enhancements or improvements to existing features" },
        { name: "Type/Task", color: "1d76db", description: "General task that does not fit into other categories" },
        { name: "Type/UX", color: "1d76db", description: "Refers to user experience-related tasks or issues" },
        { name: "Type/Question", color: "1d76db", description: "Highlights queries or clarifications needed" },
        { name: "Type/Docs", color: "1d76db", description: "Indicates documentation-related tasks or updates" },
        { name: "Severity/Blocker", color: "b60205", description: "Represents a blocking issue that prevents progress" },
        { name: "Severity/Critical", color: "b60205", description: "Indicates a critical problem requiring immediate attention" },
        { name: "Severity/Major", color: "b60205", description: "Highlights major issues but not blockers" },
        { name: "Severity/Minor", color: "b60205", description: "Marks minor issues or inconveniences" },
        { name: "Severity/Trivial", color: "b60205", description: "Denotes very low-impact issues" },
        { name: "Priority/Highest", color: "ff9900", description: "Urgent tasks requiring immediate action" },
        { name: "Priority/High", color: "ff9900", description: "High-priority tasks to be completed soon" },
        { name: "Priority/Normal", color: "ff9900", description: "Tasks with a normal priority level" },
        { name: "Priority/Low", color: "ff9900", description: "Low-priority tasks that can be deferred" },
        { name: "Resolution/Fixed", color: "93c47d", description: "Indicates issues that have been resolved" },
        { name: "Resolution/Won't Fix", color: "93c47d", description: "Marks issues that will not be addressed" },
        { name: "Resolution/Duplicate", color: "93c47d", description: "Denotes duplicate issues" },
        { name: "Resolution/Cannot Reproduce", color: "93c47d", description: "Issues that could not be replicated" },
        { name: "Resolution/Not a bug", color: "93c47d", description: "Specifies that the reported issue is not a bug" },
        { name: "Resolution/Invalid", color: "93c47d", description: "Marks invalid issues or requests" },
        { name: "Resolution/Postponed", color: "93c47d", description: "Indicates deferred tasks or issues" }
    ];
    string apiPath = string `/repos/${organization}/${repository}/labels`;
    http:Response[] responses = [];
    foreach LabelData label in labelsList {
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


# API Call to add issue template to a repository.
# 
# + organization - organization name  
# + repository - repository name 
# + authToken - GitHub Personal Access Token 
# + return - http response
public function addIssueTemplate(string organization, string repository, string authToken) 
returns error|null {
    io:println("Accessing addIssueTemplate() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });

    string filePath = "resources/github_templates/issue_template.md";
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
# + authToken - GitHub Personal Access Token 
# + return - http response
public function addPRTemplate(string organization, string repository, string authToken) 
returns error|null {
    io:println("Accessing addPRTemplate() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
    string filePath = "resources/github_templates/pull_request_template.md";
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
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addBranchProtection(string organization, string repository, string branch_protection, string authToken) 
returns error|null {
    io:println("Accessing addBranchProtection() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
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
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addTeams(string organization, string repository, string[] teams, boolean enable_triage_wso2all,boolean enable_triage_wso2allinterns,string authToken) 
returns error|null {
    io:println("Accessing addTeams() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
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