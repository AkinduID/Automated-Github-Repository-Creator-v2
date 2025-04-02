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
public function createRepoRequestMail(map<string> payload) returns error? {
    string templatePath = "resources/email_templates/create_request.html";
    string emailBody = check createEmailBody(payload,templatePath);
    check sendEmail(payload, emailBody);
}

# Send an email notifying the update of a repository request.
# 
# + payload - repository request object
# + return - error
public function updateRepoRequestMail(map<string> payload) returns error? {
    string templatePath = "resources/email_templates/update_request.html";
    string emailBody = check createEmailBody(payload,templatePath);
    check sendEmail(payload, emailBody);
}
    
# Send an email notifying the comment on a repository request.
# 
# + payload - comment object
# + return - error
public function commentRepoRequestMail(map<string> payload) returns error? {
    string templatePath = "resources/email_templates/comment_request.html";
    string emailBody = check createEmailBody(payload,templatePath);
    check sendEmail(payload, emailBody);
}

# Send an email notifying the approval of a repository request.
# 
# + payload- repository request object
# + return - error
public function approveRepoRequestMail(map<string> payload) returns error? {
    string templatePath = "resources/email_templates/approve_request.html";
    string emailBody = check createEmailBody(payload,templatePath);
    check sendEmail(payload, emailBody);
}