import ballerina/sql;

// Database Configuration record type
type DatabaseConfig record {|
    string user; // User of the database
    string password; // Password of the database
    string database; // Name of the database
    string host;  // Host of the database
    int port; // Port
|};

// RepositoryRequest record type.
public type RepositoryRequest record {|
    @sql:Column {name: "id"} readonly int id;// Repository Request ID
    @sql:Column {name: "email"} string email; // Email of the requester
    @sql:Column {name: "lead_email"} string leadEmail; // Email of the lead
    @sql:Column {name: "requirement"} string requirement; // Requirement details
    @sql:Column {name: "cc_list"} string ccList; // CC List for the request
    @sql:Column {name: "repo_name"} string repoName;
    @sql:Column {name: "organization"} string organization;
    @sql:Column {name: "repo_type"} string repoType;
    @sql:Column {name: "description"} string description;
    @sql:Column {name: "enable_issues"} boolean enableIssues;
    @sql:Column {name: "website_url"} string? websiteUrl;
    @sql:Column {name: "topics"} string? topics;
    @sql:Column {name: "pr_protection"} string prProtection;
    @sql:Column {name: "teams"} string? teams;
    @sql:Column {name: "enable_triage_wso2all"} boolean? enableTriageWso2All;
    @sql:Column {name: "enable_triage_wso2allinterns"} boolean? enableTriageWso2AllInterns;
    @sql:Column {name: "disable_triage_reason"} string? disableTriageReason;
    @sql:Column {name: "cicd_requirement"} string cicdRequirement;
    @sql:Column {name: "jenkins_job_type"} string? jenkinsJobType;
    @sql:Column {name: "jenkins_group_id"} string? jenkinsGroupId;
    @sql:Column {name: "azure_devops_org"} string? azureDevopsOrg;
    @sql:Column {name: "azure_devops_project"}string? azureDevopsProject;
    @sql:Column {name: "timestamp"}string timestamp;
    @sql:Column {name: "approval_state"}string approvalState;
    @sql:Column {name: "comments"}string? comments;
    @sql:Column {name: "email_thread_id"}string? emailThreadId;
|};

// RepositoryRequest create record type
public type RepositoryRequestCreate record {|
    string email;
    string leadEmail;
    string requirement;
    string ccList;
    string repoName;
    string organization;
    string repoType;
    string description;
    boolean enableIssues;
    string websiteUrl;
    string? topics;
    string prProtection;
    string? teams;
    boolean? enableTriageWso2All;
    boolean? enableTriageWso2AllInterns;
    string? disableTriageReason;
    string cicdRequirement;
    string? jenkinsJobType;
    string? jenkinsGroupId;
    string? azureDevopsOrg;
    string? azureDevopsProject;
    string? approvalState;
    string? comments;
    string? emailThreadId;
|};

// RepositoryRequest update record type
public type RepositoryRequestUpdate record {|
    string? email = ();
    string? leadEmail = ();
    string? requirement = ();
    string? ccList = ();
    string? repoName = ();
    string? organization = ();
    string? repoType = ();
    string? description = ();
    boolean? enableIssues = ();
    string? websiteUrl = ();
    string? topics = ();
    string? prProtection = ();
    string? teams = ();
    boolean? enableTriageWso2All = ();
    boolean? enableTriageWso2AllInterns = ();
    string? disableTriageReason = ();
    string? cicdRequirement = ();
    string? jenkinsJobType = ();
    string? jenkinsGroupId = ();
    string? azureDevopsOrg = ();
    string? azureDevopsProject = ();
    string? approvalState = ();
    string? comments = ();
    string? emailThreadId = ();
|};
