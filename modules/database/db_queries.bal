import ballerina/sql;

// Query to get PAT
isolated function getPatQuery(string organization) returns sql:ParameterizedQuery => `
    SELECT token FROM github_tokens WHERE name = ${organization};`;

// Query to get a specific repository request by id
isolated function getRepositoryRequestQuery(int id) returns sql:ParameterizedQuery => `
    SELECT id, email, lead_email, requirement, cc_list, 
        repo_name, organization, repo_type, description, enable_issues, website_url, topics,
        pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
        cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
        timestamp, approval_state, comments
    FROM repository_requests WHERE id = ${id};`;

// Query to get all repository requests created by a user (member or lead)
isolated function getRepositoryRequestsByUserQuery(string member_email) returns sql:ParameterizedQuery => `
    SELECT id, email, lead_email, requirement, cc_list, 
        repo_name, organization, repo_type, description, enable_issues, website_url, topics,
        pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
        cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
        timestamp, approval_state, comments
    FROM repository_requests WHERE email = ${member_email};`;

// Query to get all repository requests for a lead
isolated function getRepositoryRequestsByLeadQuery(string lead_email) returns sql:ParameterizedQuery => `
    SELECT id, email, lead_email, requirement, cc_list, 
        repo_name, organization, repo_type, description, enable_issues, website_url, topics,
        pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
        cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
        timestamp, approval_state, comments
    FROM repository_requests WHERE lead_email = ${lead_email};`;

// // Query to get all repository requests
// isolated function getAllRepositoryRequestsQuery() returns sql:ParameterizedQuery => `
//     SELECT id, email, lead_email, requirement, cc_list, 
//         repo_name, organization, repo_type, description, enable_issues, website_url, topics,
//         pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
//         cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
//         timestamp, approval_state, comments
//     FROM repository_requests;`;

// Query to insert a new repository request
isolated function insertRepositoryRequestQuery(RepositoryRequestCreate payload) returns sql:ParameterizedQuery => `
    INSERT INTO repository_requests (
            email, lead_email, requirement, cc_list,
            repo_name, organization, repo_type, description, enable_issues, website_url, topics, 
            pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
            cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
            approval_state, comments
    )
    VALUES
        (
            ${payload.email}, ${payload.lead_email}, ${payload.requirement}, ${payload.ccList},
            ${payload.repoName}, ${payload.organization}, ${payload.repoType}, ${payload.description}, ${payload.enableIssues}, ${payload.websiteUrl}, ${payload.topics},
            ${payload.prProtection}, ${payload.teams}, ${payload.enableTriageWso2All}, ${payload.enableTriageWso2AllInterns}, ${payload.disableTriageReason},
            ${payload.cicdRequirement}, ${payload.jenkinsJobType}, ${payload.jenkinsGroupId}, ${payload.azureDevopsOrg}, ${payload.azureDevopsProject},
            ${payload.approvalState}, ${payload.comments}
        )
`;

// Query to delete a repository request by id
isolated function deleteRepositoryRequestQuery(int requestId) returns sql:ParameterizedQuery => `
    DELETE FROM repository_requests WHERE id = ${requestId};
`;

// Query to update a repository request by id
isolated function updateRepositoryRequestQuery(int requestId, RepositoryRequestUpdate payload) returns sql:ParameterizedQuery =>`
UPDATE repository_requests
SET
lead_email = COALESCE(${payload.lead_email}, lead_email),
requirement = COALESCE(${payload.requirement}, requirement),
cc_list = COALESCE(${payload.ccList}, cc_list),
repo_name = COALESCE(${payload.repoName}, repo_name),
organization = COALESCE(${payload.organization}, organization),
repo_type = COALESCE(${payload.repoType}, repo_type),
description = COALESCE(${payload.description}, description),
enable_issues = COALESCE(${payload.enableIssues}, enable_issues),
website_url = COALESCE(${payload.websiteUrl}, website_url),
topics = COALESCE(${payload.topics}, topics),
pr_protection = COALESCE(${payload.prProtection}, pr_protection),
teams = COALESCE(${payload.topics}, teams),
enable_triage_wso2all = COALESCE(${payload.enableTriageWso2All}, enable_triage_wso2all),
enable_triage_wso2allinterns = COALESCE(${payload.enableTriageWso2AllInterns}, enable_triage_wso2allinterns),
disable_triage_reason = COALESCE(${payload.disableTriageReason}, disable_triage_reason),
cicd_requirement = COALESCE(${payload.cicdRequirement}, cicd_requirement),
jenkins_job_type = COALESCE(${payload.jenkinsJobType}, jenkins_job_type),
jenkins_group_id = COALESCE(${payload.jenkinsGroupId}, jenkins_group_id),
azure_devops_org = COALESCE(${payload.azureDevopsOrg}, azure_devops_org),
azure_devops_project = COALESCE(${payload.azureDevopsProject}, azure_devops_project)
WHERE id = ${requestId};
`; 


isolated function commentRepositoryRequestQuery(int requestId, RepositoryRequestUpdate payload) returns sql:ParameterizedQuery =>`
    UPDATE repository_requests
    SET
    comments = COALESCE(${payload.comments}, comments)
    WHERE id = ${requestId};
    `; 

isolated function approveRepositoryRequestQuery(int requestId) returns sql:ParameterizedQuery =>`
    UPDATE repository_requests
    SET
    approval_state = COALESCE("Approved", approval_state)
    WHERE id = ${requestId};
    `; 