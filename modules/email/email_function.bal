# Send an email notifying the creation of a new repository request.
# 
# + request - repository request object
# + return - error
public function createRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/create_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    check sendEmail(request, emailBody);
}

# Send an email notifying the update of a repository request.
# 
# + updatedRequest - repository request object
# + return - error
public function updateRepoRequestMail(Request updatedRequest) returns error? {
    string templatePath = "resources/email_templates/update_request.html";
    string emailBody = check createEmailBody(updatedRequest,templatePath);
    check sendEmail(updatedRequest, emailBody);
}
    
# Send an email notifying the comment on a repository request.
# 
# + request - comment object
# + return - error
public function commentRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/comment_request.html";
    string emailBody = check createEmailBody(request,templatePath);
     check sendEmail(request, emailBody);
}

# Send an email notifying the approval of a repository request.
# 
# + request - repository request object
# + return - error
public function approveRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/approve_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    check sendEmail(request, emailBody);
}