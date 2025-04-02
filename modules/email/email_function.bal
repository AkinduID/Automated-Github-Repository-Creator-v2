// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
// import ballerina/regex;

# Send an email notifying the creation of a new repository request.
# 
# + request - repository request object
# + return - error
public function createRepoRequestMail(repositoryRequest request) returns error? {
    string templatePath = "resources/email_templates/create_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    check sendEmail(request, emailBody);
}

# Send an email notifying the update of a repository request.
# 
# + updatedRequest - repository request object
# + return - error
public function updateRepoRequestMail(repositoryRequest updatedRequest) returns error? {
    string templatePath = "resources/email_templates/update_request.html";
    string emailBody = check createEmailBody(updatedRequest,templatePath);
    check sendEmail(updatedRequest, emailBody);
}
    
# Send an email notifying the comment on a repository request.
# 
# + request - comment object
# + return - error
public function commentRepoRequestMail(repositoryRequest request) returns error? {
    string templatePath = "resources/email_templates/comment_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    check sendEmail(request, emailBody);
}

# Send an email notifying the approval of a repository request.
# 
# + request - repository request object
# + return - error
public function approveRepoRequestMail(repositoryRequest request) returns error? {
    string templatePath = "resources/email_templates/approve_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    check sendEmail(request, emailBody);
}