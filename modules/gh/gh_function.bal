// import ballerinax/github;
// import ballerina/github;
// import ballerina/http;
// import ballerina/encoding;
import ballerina/io;
import ballerina/http;
import ballerina/regex;



# Description.
# API Call to create a new repository in GitHub.
# + organization - Organization name
# + repoName - repository name 
# + repoDesc - repository description  
# + isPrivate - repository type (false - public/ true - private) 
# + enableIssues - enable issues  
# + websiteUrl - website URL (optional)  
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function createRepository(string organization, string repoName, string repoDesc, boolean isPrivate, boolean enableIssues, string? websiteUrl, string authToken) 
returns http:Response|error {
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
    io:print("Response: ", response.getJsonPayload());
    return response;
}

# Description.
# API Call to add topics to a repository
# + organization - organization name  
# + repository - repository name 
# + topicList - list of topics to be added  
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addTopics(string organization, string repository, string[] topicList, string authToken) 
returns http:Response | error {
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
    io:print("Response: ", response.getJsonPayload());
    return response;
}


# Description.
# API Call to add labels to a repository
# + organization - organization name
# + repository - repository name
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addLabels(string organization, string repository, string authToken) 
returns http:Response[]| error {
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
        io:print("Response: ", response.getJsonPayload());
    }
    return responses;
}


# Description.
# API Call to add issue template to a repository
# + organization - organization name  
# + repository - repository name 
# + authToken - GitHub Personal Access Token 
# + return - http response
public function addIssueTemplate(string organization, string repository, string authToken) 
returns http:Response | error {
    io:println("Accessing addIssueTemplate() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
    string templateContent = "KipEZXNjcmlwdGlvbjoqKg0KPCEtLSBHaXZlIGEgYnJpZWYgZGVzY3JpcHRpb24gb2YgdGhlIGlzc3VlIC0tPg0KDQoqKlN1Z2dlZCBMYWJlbHM6KioNCjwhLS0gT3B0aW9uYWwgY29tbWEgc2VwYXJhdGVkIGxpc3Qgb2Ygc3VnZ2VzdGVkIGxhYmVscy4gTm9uIGNvbW1pdHRlcnMgY2Fu4oCZdCBhc3NpZ24gbGFiZWxzIHRvIGlzc3Vlcywgc28gdGhpcyB3aWxsIGhlbHAgaXNzdWUgY3JlYXRvcnMgd2hvIGFyZSBub3QgYSBjb21taXR0ZXIgdG8gc3VnZ2VzdCBwb3NzaWJsZSBsYWJlbHMtLT4NCg0KKipTdWdnZXN0ZWQgQXNzaWduZWVzOioqDQo8IS0tT3B0aW9uYWwgY29tbWEgc2VwYXJhdGVkIGxpc3Qgb2Ygc3VnZ2VzdGVkIHRlYW0gbWVtYmVycyB3aG8gc2hvdWxkIGF0dGVuZCB0aGUgaXNzdWUuIE5vbiBjb21taXR0ZXJzIGNhbuKAmXQgYXNzaWduIGlzc3VlcyB0byBhc3NpZ25lZXMsIHNvIHRoaXMgd2lsbCBoZWxwIGlzc3VlIGNyZWF0b3JzIHdobyBhcmUgbm90IGEgY29tbWl0dGVyIHRvIHN1Z2dlc3QgcG9zc2libGUgYXNzaWduZWVzLS0+DQoNCioqQWZmZWN0ZWQgUHJvZHVjdCBWZXJzaW9uOioqDQoNCioqT1MsIERCLCBvdGhlciBlbnZpcm9ubWVudCBkZXRhaWxzIGFuZCB2ZXJzaW9uczoqKiAgICANCg0KKipTdGVwcyB0byByZXByb2R1Y2U6KioNCg0KDQoqKlJlbGF0ZWQgSXNzdWVzOioqDQo8IS0tIEFueSByZWxhdGVkIGlzc3VlcyBzdWNoIGFzIHN1YiB0YXNrcywgaXNzdWVzIHJlcG9ydGVkIGluIG90aGVyIHJlcG9zaXRvcmllcyAoZS5nIGNvbXBvbmVudCByZXBvc2l0b3JpZXMpLCBzaW1pbGFyIHByb2JsZW1zLCBldGMuIC0tPg==";
    json issueTemplate = {
        message: "Add Issue Template",
        content: templateContent,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/issue_template.md`;
    http:Response response = check githubClient->put(apiPath, issueTemplate);
    io:print("Response: ", response.getJsonPayload());
    return response;
}

# Description.
# API Call to add pull request template to a repository
# + organization - organization name
# + repository - repository name
# + authToken - GitHub Personal Access Token 
# + return - http response
public function addPRTemplate(string organization, string repository, string authToken) 
returns http:Response | error {
    io:println("Accessing addPRTemplate() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: authToken
        }
    });
    string templateContent = "IyMgUHVycG9zZQ0KPiBEZXNjcmliZSB0aGUgcHJvYmxlbXMsIGlzc3Vlcywgb3IgbmVlZHMgZHJpdmluZyB0aGlzIGZlYXR1cmUvZml4IGFuZCBpbmNsdWRlIGxpbmtzIHRvIHJlbGF0ZWQgaXNzdWVzIGluIHRoZSBmb2xsb3dpbmcgZm9ybWF0OiBSZXNvbHZlcyBpc3N1ZTEsIGlzc3VlMiwgZXRjLg0KDQojIyBHb2Fscw0KPiBEZXNjcmliZSB0aGUgc29sdXRpb25zIHRoYXQgdGhpcyBmZWF0dXJlL2ZpeCB3aWxsIGludHJvZHVjZSB0byByZXNvbHZlIHRoZSBwcm9ibGVtcyBkZXNjcmliZWQgYWJvdmUNCg0KIyMgQXBwcm9hY2gNCj4gRGVzY3JpYmUgaG93IHlvdSBhcmUgaW1wbGVtZW50aW5nIHRoZSBzb2x1dGlvbnMuIEluY2x1ZGUgYW4gYW5pbWF0ZWQgR0lGIG9yIHNjcmVlbnNob3QgaWYgdGhlIGNoYW5nZSBhZmZlY3RzIHRoZSBVSSAoZW1haWwgZG9jdW1lbnRhdGlvbkB3c28yLmNvbSB0byByZXZpZXcgYWxsIFVJIHRleHQpLiBJbmNsdWRlIGEgbGluayB0byBhIE1hcmtkb3duIGZpbGUgb3IgR29vZ2xlIGRvYyBpZiB0aGUgZmVhdHVyZSB3cml0ZS11cCBpcyB0b28gbG9uZyB0byBwYXN0ZSBoZXJlLg0KDQojIyBVc2VyIHN0b3JpZXMNCj4gU3VtbWFyeSBvZiB1c2VyIHN0b3JpZXMgYWRkcmVzc2VkIGJ5IHRoaXMgY2hhbmdlPg0KDQojIyBSZWxlYXNlIG5vdGUNCj4gQnJpZWYgZGVzY3JpcHRpb24gb2YgdGhlIG5ldyBmZWF0dXJlIG9yIGJ1ZyBmaXggYXMgaXQgd2lsbCBhcHBlYXIgaW4gdGhlIHJlbGVhc2Ugbm90ZXMNCg0KIyMgRG9jdW1lbnRhdGlvbg0KPiBMaW5rKHMpIHRvIHByb2R1Y3QgZG9jdW1lbnRhdGlvbiB0aGF0IGFkZHJlc3NlcyB0aGUgY2hhbmdlcyBvZiB0aGlzIFBSLiBJZiBubyBkb2MgaW1wYWN0LCBlbnRlciDigJxOL0HigJ0gcGx1cyBicmllZiBleHBsYW5hdGlvbiBvZiB3aHkgdGhlcmXigJlzIG5vIGRvYyBpbXBhY3QNCg0KIyMgVHJhaW5pbmcNCj4gTGluayB0byB0aGUgUFIgZm9yIGNoYW5nZXMgdG8gdGhlIHRyYWluaW5nIGNvbnRlbnQgaW4gaHR0cHM6Ly9naXRodWIuY29tL3dzbzIvV1NPMi1UcmFpbmluZywgaWYgYXBwbGljYWJsZQ0KDQojIyBDZXJ0aWZpY2F0aW9uDQo+IFR5cGUg4oCcU2VudOKAnSB3aGVuIHlvdSBoYXZlIHByb3ZpZGVkIG5ldy91cGRhdGVkIGNlcnRpZmljYXRpb24gcXVlc3Rpb25zLCBwbHVzIGZvdXIgYW5zd2VycyBmb3IgZWFjaCBxdWVzdGlvbiAoY29ycmVjdCBhbnN3ZXIgaGlnaGxpZ2h0ZWQgaW4gYm9sZCksIGJhc2VkIG9uIHRoaXMgY2hhbmdlLiBDZXJ0aWZpY2F0aW9uIHF1ZXN0aW9ucy9hbnN3ZXJzIHNob3VsZCBiZSBzZW50IHRvIGNlcnRpZmljYXRpb25Ad3NvMi5jb20gYW5kIE5PVCBwYXN0ZWQgaW4gdGhpcyBQUi4gSWYgdGhlcmUgaXMgbm8gaW1wYWN0IG9uIGNlcnRpZmljYXRpb24gZXhhbXMsIHR5cGUg4oCcTi9B4oCdIGFuZCBleHBsYWluIHdoeS4NCg0KIyMgTWFya2V0aW5nDQo+IExpbmsgdG8gZHJhZnRzIG9mIG1hcmtldGluZyBjb250ZW50IHRoYXQgd2lsbCBkZXNjcmliZSBhbmQgcHJvbW90ZSB0aGlzIGZlYXR1cmUsIGluY2x1ZGluZyBwcm9kdWN0IHBhZ2UgY2hhbmdlcywgdGVjaG5pY2FsIGFydGljbGVzLCBibG9nIHBvc3RzLCB2aWRlb3MsIGV0Yy4sIGlmIGFwcGxpY2FibGUNCg0KIyMgQXV0b21hdGlvbiB0ZXN0cw0KIC0gVW5pdCB0ZXN0cyANCiAgID4gQ29kZSBjb3ZlcmFnZSBpbmZvcm1hdGlvbg0KIC0gSW50ZWdyYXRpb24gdGVzdHMNCiAgID4gRGV0YWlscyBhYm91dCB0aGUgdGVzdCBjYXNlcyBhbmQgY292ZXJhZ2UNCg0KIyMgU2VjdXJpdHkgY2hlY2tzDQogLSBGb2xsb3dlZCBzZWN1cmUgY29kaW5nIHN0YW5kYXJkcyBpbiBodHRwOi8vd3NvMi5jb20vdGVjaG5pY2FsLXJlcG9ydHMvd3NvMi1zZWN1cmUtZW5naW5lZXJpbmctZ3VpZGVsaW5lcz8geWVzL25vDQogLSBSYW4gRmluZFNlY3VyaXR5QnVncyBwbHVnaW4gYW5kIHZlcmlmaWVkIHJlcG9ydD8geWVzL25vDQogLSBDb25maXJtZWQgdGhhdCB0aGlzIFBSIGRvZXNuJ3QgY29tbWl0IGFueSBrZXlzLCBwYXNzd29yZHMsIHRva2VucywgdXNlcm5hbWVzLCBvciBvdGhlciBzZWNyZXRzPyB5ZXMvbm8NCg0KIyMgU2FtcGxlcw0KPiBQcm92aWRlIGhpZ2gtbGV2ZWwgZGV0YWlscyBhYm91dCB0aGUgc2FtcGxlcyByZWxhdGVkIHRvIHRoaXMgZmVhdHVyZQ0KDQojIyBSZWxhdGVkIFBScw0KPiBMaXN0IGFueSBvdGhlciByZWxhdGVkIFBScw0KDQojIyBNaWdyYXRpb25zIChpZiBhcHBsaWNhYmxlKQ0KPiBEZXNjcmliZSBtaWdyYXRpb24gc3RlcHMgYW5kIHBsYXRmb3JtcyBvbiB3aGljaCBtaWdyYXRpb24gaGFzIGJlZW4gdGVzdGVkDQoNCiMjIFRlc3QgZW52aXJvbm1lbnQNCj4gTGlzdCBhbGwgSkRLIHZlcnNpb25zLCBvcGVyYXRpbmcgc3lzdGVtcywgZGF0YWJhc2VzLCBhbmQgYnJvd3Nlci92ZXJzaW9ucyBvbiB3aGljaCB0aGlzIGZlYXR1cmUvZml4IHdhcyB0ZXN0ZWQNCiANCiMjIExlYXJuaW5nDQo+IERlc2NyaWJlIHRoZSByZXNlYXJjaCBwaGFzZSBhbmQgYW55IGJsb2cgcG9zdHMsIHBhdHRlcm5zLCBsaWJyYXJpZXMsIG9yIGFkZC1vbnMgeW91IHVzZWQgdG8gc29sdmUgdGhlIHByb2JsZW0u";
    json issueTemplate = {
        message: "Add PR Template",
        content: templateContent,
        branch: "main"
    };
    string apiPath = string `/repos/${organization}/${repository}/contents/pull_request_template.md`;
    http:Response response = check githubClient->put(apiPath, issueTemplate);
    io:print("Response: ", response.getJsonPayload());
    return response;
}

# Description.
# API Call to add branch protection to a repository
# + organization - organization name 
# + repository - repository name 
# + branch_protection - branch protection type (Default/Bal)
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addBranchProtection(string organization, string repository, string branch_protection, string authToken) 
returns http:Response | error {
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
    io:print("Response: ", response.getJsonPayload());
    io:print("Response status code: ", response.statusCode);
    return response;
}

# Description.
# Function to add Default teams to team list
# + organization - organization name
# + teams - list of teams
# + return - updated list of teams
public isolated function addDefaultTeams(string organization, string[] teams) returns string[]{
    teams.push("Infra");
    teams.push("gitopslab-all");
    teams.push("gitopslab-all-interns");
    if organization == "gitopslab-extensions"{
        teams.push("connector-store-rw-bot");
    }
    if organization != "gitopslab_incubator"{
        teams.push("engineering-readonly-bots");
    }
    string[] otherTeams = [];
    foreach string team in teams {
        if string:includes(team, "-internal-commiters") {
            if organization == "wso2-enterprise" {
                otherTeams.push(regex:replace(team, "-internal-commiters", "-readonly"));
            }
            else{
                otherTeams.push(regex:replace(team, "-internal-commiters", "-external-commiters"));
            }
        }
    }
    teams.push(...otherTeams);
    string[] slugs = createSlug(teams);
    return slugs;
}

# Description.
# Function to create slugs for team names
# + teamList - list of team names
# + return - list of slugs
public isolated function createSlug(string[] teamList) returns string[] {
    string[] slugs = [];
    foreach string name in teamList {
        string normalized = regex:replaceAll(name, "[^a-zA-Z0-9\\s-]", "");
        string lowerCased = string:toLowerAscii(normalized);
        string slug = regex:replaceAll(lowerCased, "\\s+", "-");
        slugs.push(slug);
    }
    return slugs;
}

# Description.
# API Call to add teams to a repository
# + organization - organization name  
# + repository - repository name 
# + teams - list of teams to be added 
# + enable_triage_wso2all - enable triage for wso2all team 
# + enable_triage_wso2allinterns - enable triage for wso2allinterns team
# + authToken - GitHub Personal Access Token
# + return - http response
public isolated function addTeams(string organization, string repository, string[] teams, boolean enable_triage_wso2all,boolean enable_triage_wso2allinterns,string authToken) returns http:Response[] | error {
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
        io:println("Response: ", response.getJsonPayload());
        io:println("______________________________");
        responses.push(response);
    }
    return responses;
}