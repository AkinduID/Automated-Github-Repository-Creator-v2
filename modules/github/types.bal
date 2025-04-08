// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

# Record to represent a GitHub team.
public type GitHubTeam record {|
    # Team slug
    string slug;
|};

# Record to represent the data field in the response.
public type GitHubTeamsData record {|
    # List of GitHub teams
    GitHubTeam[] githubTeams;
|};

# Record to represent the full response.
public type GitHubTeamsResponse record {|
    # Data field containing the list of GitHub teams
    GitHubTeamsData data;
|};

# Record to represent github label data
public type LabelData record {
    # Label ID
    string name;
    # Label color
    string color;
    # Label description
    string description;
};

# Record to represent the result of a GitHub operation.
public type gitHubOperationResult record {
    # Name of the operation (e.g., "Add Topics", "Add Labels").
    string operation;
    # Status of the operation (e.g., "success", "failure").
    string status;
    # Optional error message if the operation failed.
    string|null errorMessage;
};

# Record to represent repository creation input.
public type CreateRepoInput record {
    # The organization name. The name is not case sensitive.
    string orgName;
    # Repository name
    string repoName;
    # Pass true to create an initial commit with empty README
    boolean autoInit = true;
    # Pass true to create a private repository
    boolean isPrivate;
    # Repository description
    string repoDescription;
    # Repository homepage
    string repoHomepage?;
    # Pass true to enable issues
    boolean enableIssues;
    # Pass true to enable wiki
    boolean enableWiki = false;
    # license template
    string licenseTemplate = "apache-2.0";
    # gitignore template
    string gitignoreTemplate = "Java";
};

public type AddTopicsInput record {|
    # The organization name. The name is not case sensitive.
    string orgName;
    # The name of the repository without the .git extension. The name is not case sensitive.
    string repoName;
    # The topics to add to the repository
    string[] topics;
|};

public type AddBranchProtectionInput record{
    # The organization name. The name is not case sensitive.
    string orgName;
    # The name of the repository without the .git extension. The name is not case sensitive.
    string repoName;
    # The type of branchprotection to be applied to the repository
    string branchProtection;
};

public type AddTeamInput record {
    # The organization name. The name is not case sensitive.
    string orgName;
    # The name of the repository without the .git extension. The name is not case sensitive.
    string repoName;
    # The name of the team to add to the repository
    string[] teams;
    # pass true to enable tirage acces to wso2all team in wso2-enterpirse org
    boolean enable_triage_wso2all;
    # pass true to enable tirage acces to wso2allinterns team in wso2-enterpirse org
    boolean enable_triage_wso2allinterns;
};
