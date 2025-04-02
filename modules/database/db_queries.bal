// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/sql;

# Query to get PAT
#
# + organization - organization name
# + return - Personal Access Token (PAT) for the organization
isolated function getPatQuery(string organization)
    returns sql:ParameterizedQuery => `
    SELECT 
        token 
    FROM 
        github_tokens 
    WHERE 
        name = ${organization};
    `;

# Query to get a specific repository request by id
#
# + id - Repository request id
# + return - RepositoryRequest object
isolated function getRepositoryRequestQuery(int id)
    returns sql:ParameterizedQuery => `
    SELECT 
        id, 
        email, 
        lead_email, 
        requirement, 
        cc_list, 
        repo_name, 
        organization, 
        repo_type, 
        description, 
        enable_issues, 
        website_url, 
        topics, 
        pr_protection, 
        teams, 
        enable_triage_wso2all, 
        enable_triage_wso2allinterns, 
        disable_triage_reason, 
        cicd_requirement, 
        jenkins_job_type, 
        jenkins_group_id, 
        azure_devops_org, 
        azure_devops_project, 
        timestamp, 
        approval_state, 
        comment 
    FROM 
        repository_requests 
    WHERE 
        id = ${id};
    `;

# Query to get all repository requests created by a user (member or lead)
#
# + memberEmail - member email
# + leadEmail - lead email
# + return - repository requests created by the user or sql:Error
# + return - sql:NoRowsError
isolated function getRepositoryRequestsQuery(string? memberEmail, string? leadEmail)
    returns sql:ParameterizedQuery {
    return `
        SELECT 
            id, 
            email, 
            lead_email, 
            requirement, 
            cc_list, 
            repo_name, 
            organization, 
            repo_type, 
            description, 
            enable_issues, 
            website_url, 
            topics, 
            pr_protection, 
            teams, 
            enable_triage_wso2all, 
            enable_triage_wso2allinterns, 
            disable_triage_reason, 
            cicd_requirement, 
            jenkins_job_type, 
            jenkins_group_id, 
            azure_devops_org, 
            azure_devops_project, 
            timestamp, 
            approval_state, 
            comment 
        FROM 
            repository_requests 
        WHERE 
            (email = ${memberEmail} OR ${memberEmail} IS NULL) AND 
            (lead_email = ${leadEmail} OR ${leadEmail} IS NULL);
    `;
}

# Query to insert a new repository request
#
# + payload - RepositoryRequestCreate object
# + return - newly inserted RepositoryRequest object or sql:Error
isolated function insertRepositoryRequestQuery(RepositoryRequestCreate payload)
    returns sql:ParameterizedQuery => `
    INSERT INTO repository_requests (
            email, lead_email, requirement, cc_list,
            repo_name, organization, repo_type, description, enable_issues, website_url, topics, 
            pr_protection, teams, enable_triage_wso2all, enable_triage_wso2allinterns, disable_triage_reason,
            cicd_requirement, jenkins_job_type, jenkins_group_id, azure_devops_org, azure_devops_project,
            approval_state, comment
    )
    VALUES
        (
            ${payload.email}, ${payload.lead_email}, ${payload.requirement}, ${payload.ccList},
            ${payload.repoName}, ${payload.organization}, ${payload.repoType}, ${payload.description}, ${payload.enableIssues}, ${payload.websiteUrl}, ${payload.topics},
            ${payload.prProtection}, ${payload.teams}, ${payload.enableTriageWso2All}, ${payload.enableTriageWso2AllInterns}, ${payload.disableTriageReason},
            ${payload.cicdRequirement}, ${payload.jenkinsJobType}, ${payload.jenkinsGroupId}, ${payload.azureDevopsOrg}, ${payload.azureDevopsProject},
            ${payload.approvalState}, ${payload.comment}
        )
`;

# Query to delete a repository request by id
#
# + requestId - Repository request id
# + return - sql:ParameterizedQuery
isolated function deleteRepositoryRequestQuery(int requestId)
    returns sql:ParameterizedQuery => `
    DELETE FROM repository_requests WHERE id = ${requestId};
`;

# Query to update a repository request by id
#
# + requestId - Repository request id
# + payload - RepositoryRequestUpdate object
# + return - sql:ParameterizedQuery
isolated function updateRepositoryRequestQuery(int requestId, RepositoryRequestUpdate payload)
    returns sql:ParameterizedQuery => `
    UPDATE 
        repository_requests
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
    WHERE 
        id = ${requestId};
    `;

# Query to update the comment of a repository request
#
# + requestId - Repository request id
# + payload - RepositoryRequestUpdate object
# + return - sql:ParameterizedQuery
isolated function commentRepositoryRequestQuery(int requestId, RepositoryRequestUpdate payload)
    returns sql:ParameterizedQuery => `
    UPDATE 
        repository_requests
    SET
        comment = COALESCE(${payload.comment}, comment)
    WHERE 
        id = ${requestId};
    `;

# Query to approve a repository request
#
# + requestId - Repository request id
# + return - sql:ParameterizedQuery
isolated function approveRepositoryRequestQuery(int requestId)
    returns sql:ParameterizedQuery => `
    UPDATE 
        repository_requests
    SET
        approval_state = COALESCE("Approved", approval_state) 
    WHERE 
        id = ${requestId};
    `;

// TODO: get status from enum. remove COALESCE
