// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/sql;
import ballerinax/mysql;

# Database Configuration record type set
type DatabaseConfig record {|
    # user
    string user;
    # password
    string password;
    # database
    string database;
    # host
    string host;
    # port
    int port;
    # SSL mode
    mysql:SSLMode sslMode;
|};

# RepositoryRequest record type.
public type RepositoryRequest record {|
    # Repository Request ID
    @sql:Column {name: "id"}
    readonly int id;
    # Email of the requester
    @sql:Column {name: "email"}
    string email;
    # Email of the lead
    @sql:Column {name: "lead_email"}
    string leadEmail;
    # Requirement details
    @sql:Column {name: "requirement"}
    string requirement;
    # CC List for the request
    @sql:Column {name: "cc_list"}
    string ccList;
    # Repository name
    @sql:Column {name: "repo_name"}
    string repoName;
    # Organization name
    @sql:Column {name: "organization"}
    string organization;
    # Repository type
    @sql:Column {name: "repo_type"}
    string repoType;
    # Repository description
    @sql:Column {name: "description"}
    string description;
    # Enable issues
    @sql:Column {name: "enable_issues"}
    string enableIssues;
    # Website URL
    @sql:Column {name: "website_url"}
    string? websiteUrl;
    # Topics
    @sql:Column {name: "topics"}
    string topics;
    # Pull request protection
    @sql:Column {name: "pr_protection"}
    string prProtection;
    # Teams
    @sql:Column {name: "teams"}
    string teams;
    # Enable triage for WSO2 All team
    @sql:Column {name: "enable_triage_wso2_all"}
    string enableTriageWso2All;
    # Enable triage for WSO2 All Interns team
    @sql:Column {name: "enable_triage_wso2_all_interns"}
    string enableTriageWso2AllInterns;
    # Reason for disabling triage
    @sql:Column {name: "disable_triage_reason"}
    string disableTriageReason;
    # CI/CD requirement
    @sql:Column {name: "ci_cd_requirement"}
    string cicdRequirement;
    # Jenkins job type
    @sql:Column {name: "jenkins_job_type"}
    string? jenkinsJobType;
    # Jenkins group ID
    @sql:Column {name: "jenkins_group_id"}
    string? jenkinsGroupId;
    # Azure DevOps organization
    @sql:Column {name: "azure_devops_org"}
    string? azureDevopsOrg;
    # Azure DevOps project
    @sql:Column {name: "azure_devops_project"}
    string? azureDevopsProject;
    # Timestamp
    @sql:Column {name: "timestamp"}
    string timestamp;
    # Approval state
    @sql:Column {name: "approval_state"}
    string approvalState;
    # lead_comment
    @sql:Column {name: "lead_comment"}
    string? leadComment;
|};

# RepositoryRequest create record type
public type RepositoryRequestCreate record {|
    # Email of the requester
    string email;
    # Email of the lead
    string lead_email;
    # Requirement details
    string requirement;
    # CC List for the request
    string ccList;
    # Repository name
    string repoName;
    # Organization name
    string organization;
    # Repository type
    string repoType;
    # Repository description
    string description;
    # Enable issues
    boolean enableIssues;
    # Website URL
    string? websiteUrl;
    # Topics
    string topics;
    # Pull request protection
    string prProtection;
    # Teams
    string teams;
    # Enable triage for WSO2 All team
    string enableTriageWso2All;
    # Enable triage for WSO2 All Interns team
    string enableTriageWso2AllInterns;
    # Reason for disabling triage
    string disableTriageReason;
    # CI/CD requirement
    string cicdRequirement;
    # Jenkins job type
    string? jenkinsJobType;
    # Jenkins group ID
    string? jenkinsGroupId;
    # Azure DevOps organization
    string? azureDevopsOrg;
    # Azure DevOps project
    string? azureDevopsProject;
    # Approval state
    string approvalState;
    # lead_comment
    string? leadComment;
|};

# RepositoryRequest update record type
public type RepositoryRequestUpdate record {|
    # Email of the requester
    string? email = ();
    # Email of the lead
    string? lead_email = ();
    # Requirement details
    string? requirement = ();
    # CC List for the request
    string? ccList = ();
    # Repository name
    string? repoName = ();
    # Organization name
    string? organization = ();
    # Repository type
    string? repoType = ();
    # Repository description
    string? description = ();
    # Enable issues
    string? enableIssues = ();
    # Website URL
    string? websiteUrl = ();
    # Topics
    string? topics = ();
    # Pull request protection
    string? prProtection = ();
    # Teams
    string? teams = ();
    # Enable triage for WSO2 All team
    string? enableTriageWso2All = ();
    # Enable triage for WSO2 All Interns team
    string? enableTriageWso2AllInterns = ();
    # Reason for disabling triage
    string? disableTriageReason = ();
    # CI/CD requirement
    string? cicdRequirement = ();
    # Jenkins job type
    string? jenkinsJobType = ();
    # Jenkins group ID
    string? jenkinsGroupId = ();
    # Azure DevOps organization
    string? azureDevopsOrg = ();
    # Azure DevOps project
    string? azureDevopsProject = ();
    # Approval state
    string? approvalState = ();
    # lead_comment
    string? leadComment = ();
|};
