import ballerina/sql;

// Query to get all repository requests
isolated function getRepositoryRequestsQuery() returns sql:ParameterizedQuery => `
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
        comments,
        email_thread_id
    FROM 
        repository_requests;
`;

// Query to insert a new repository request
isolated function insertRepositoryRequestQuery(RepositoryRequestCreate payload) returns sql:ParameterizedQuery => `
    INSERT INTO repository_requests
        (
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
            approval_state,
            comments,
            email_thread_id
        )
    VALUES
        (
            ${payload.email},
            ${payload.leadEmail},
            ${payload.requirement},
            ${payload.ccList},
            ${payload.repoName},
            ${payload.organization},
            ${payload.repoType},
            ${payload.description},
            ${payload.enableIssues},
            ${payload.websiteUrl},
            ${payload.topics},
            ${payload.prProtection},
            ${payload.teams},
            ${payload.enableTriageWso2All},
            ${payload.enableTriageWso2AllInterns},
            ${payload.disableTriageReason},
            ${payload.cicdRequirement},
            ${payload.jenkinsJobType},
            ${payload.jenkinsGroupId},
            ${payload.azureDevopsOrg},
            ${payload.azureDevopsProject},
            ${payload.approvalState},
            ${payload.comments},
            ${payload.emailThreadId}
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
            email = COALESCE(${payload.email}, email),
            lead_email = COALESCE(${payload.leadEmail}, lead_email),
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
            azure_devops_project = COALESCE(${payload.azureDevopsProject}, azure_devops_project),
            approval_state = COALESCE(${payload.approvalState}, approval_state),
            comments = COALESCE(${payload.comments}, comments),
            email_thread_id = COALESCE(${payload.emailThreadId}, email_thread_id)
        WHERE id = ${requestId};
`;
