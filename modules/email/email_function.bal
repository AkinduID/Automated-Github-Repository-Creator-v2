import ballerina/email;
import ballerina_crud_application.database;
import ballerina/regex;
// import ballerina/io;
// import ballerina/time;


# Description.
# Send an email notifying the creation of a new repository request.
# + request - parameter description
# + return - return value description
public function createRepoRequestMail(database:RepositoryRequest request) returns error? {
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.lead_email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: string ` Hi,
                    This is a new repositoroty request.
                    ${emailBody(request)}`,
        'from: "bot@email.com",
        sender: "sender@email.com",
        replyTo: ["replyTo1@email.com", "replyTo2@email.com"]
};
    check smtpClient->sendMessage(email);
}

# Description.
# Send an email notifying the update of a repository request.
# + request - parameter description
# + return - return value description
public function updateRepoRequestMail(database:RepositoryRequest request) returns error? {
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.lead_email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: string ` Hi,
                    This is an update on the repositoroty request.
                    ${emailBody(request)}`,
        'from: "bot@email.com",
        sender: "sender@email.com",
        replyTo: ["replyTo1@email.com", "replyTo2@email.com"]
};
    check smtpClient->sendMessage(email);
}
    
# Description.
# Send an email notifying the comment on a repository request.
# + request - parameter description
# + return - return value description
public function commentRepoRequestMail(database:RepositoryRequest request) returns error? {
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: string `Hi,
                    This is a comment on your request for creating a new GitHub repository.
                    ${request.comments.toString()}
                    Please review and update your request accordingly.`,
        'from: "bot@email.com",
        sender: "sender@email.com",
        replyTo: ["replyTo1@email.com", "replyTo2@email.com"]
};
    check smtpClient->sendMessage(email);
}

# Description.
# Send an email notifying the approval of a repository request.
# + request - parameter description
# + return - return value description
public function approveRepoRequestMail(database:RepositoryRequest request) returns error? {
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: string `Hi,
                    Your request for creating a new GitHub repository has been approved.
                    Repository Link: https://github.com/${request.organization}/${request.repoName}
                    DevOps Configurations will be handled by DigiOps Team Manually.`,
        'from: "bot@email.com",
        sender: "sender@email.com",
        replyTo: ["replyTo1@email.com", "replyTo2@email.com"]
};
    check smtpClient->sendMessage(email);
}

# Description.
# Generate the email body for the repository request.
# + request - parameter description
# + return - return value description
public function emailBody(database:RepositoryRequest request) returns string {
    return string `
    Requested By: ${request.email}
    Requesting From: ${request.lead_email}
    Requirement: ${request.requirement}

    Repository Details
    Repository Name: ${request.repoName}
    Organization: ${request.organization}
    Description: ${request.description}
    Website URL: ${request.websiteUrl == null ? "Not Applicable" : request.websiteUrl.toString()}
    Topics: ${request.topics}
    Enable Issues: ${request.enableIssues.toString()}

    Security Details
    PR Protection Enabled: ${request.prProtection.toString()}
    Teams to be added: ${request.teams}
    Enable Triage for WSO2 All: ${request.organization == "gitopslab-enterprise" ? request.enableTriageWso2All.toString() : "Not Applicable"}
    Enable Triage for WSO2 All Interns: ${request.organization == "gitopslab-enterprise" ? request.enableTriageWso2AllInterns.toString() : "Not Applicable"}
    Disable Triage Reason: ${request.organization.toString() == "gitopslab-enterprise" ? request.disableTriageReason.toString() : "Not Applicable"}

    DevOps Details
    CICD Requirement: ${request.cicdRequirement}
    Jenkins Job Type: ${request.cicdRequirement == "Jenkins" ? request.jenkinsJobType.toString() : "Not Applicable"}
    Jenkins Group ID: ${request.cicdRequirement == "Jenkins" ? request.jenkinsGroupId.toString() : "Not Applicable"}
    Azure DevOps Organization: ${request.cicdRequirement == "Azure DevOps" ? request.azureDevopsOrg.toString() : "Not Applicable"}
    Azure DevOps Project: ${request.cicdRequirement == "Azure DevOps" ? request.azureDevopsProject.toString() : "Not Applicable"}
    `;
}