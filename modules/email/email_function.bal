// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

# Send an email notifying the creation of a new repository request.
#
# + payload - repository request object
# + return - error
public isolated function createRepoRequestAlert(map<string> payload)
    returns error? {

    string templatePath = "resources/email_templates/create_request.html"; //TODO: configurable paths
    string emailBody = check createEmailBody(payload, templatePath);
    check sendEmail(payload, emailBody);
}

# Send an email notifying the update of a repository request.
#
# + payload - repository request object
# + return - error
public isolated function updateRepoRequestAlert(map<string> payload)
    returns error? {

    string templatePath = "resources/email_templates/update_request.html";
    string emailBody = check createEmailBody(payload, templatePath);
    check sendEmail(payload, emailBody);
}

# Send an email notifying the comment on a repository request.
#
# + payload - comment object
# + return - error
public isolated function commentRepoRequestAlert(map<string> payload)
    returns error? {

    string templatePath = "resources/email_templates/comment_request.html";
    string emailBody = check createEmailBody(payload, templatePath);
    check sendEmail(payload, emailBody);
}

# Send an email notifying the approval of a repository request.
#
# + payload - repository request object
# + report - map containing the status of GitHub operations
# + return - error
public isolated function approveRepoRequestAlert(map<string> payload, map<string> report)
    returns error? {

    string templatePath = "resources/email_templates/approve_request.html";

    // Generate a summary of GitHub operation results as an HTML list
    string operationSummary = "<ul>";
    foreach var [operation, status] in report.entries() {
        operationSummary += string `<li>${operation}: <strong>${status}</strong></li>`;
    }
    operationSummary += "</ul>";

    // Add the operation summary to the payload
    payload["operationSummary"] = operationSummary;

    // Create the email body
    string emailBody = check createEmailBody(payload, templatePath);
    check sendEmail(payload, emailBody);
}
