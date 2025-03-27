import ballerina/email;
import ballerina/regex;

# Send an email notifying the creation of a new repository request.
# 
# + request - repository request object
# + return - error
public function createRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/create_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.lead_email,request.email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: emailBody,
        'from: emailConfig.username,
        sender: emailConfig.username,
        replyTo: [],
        contentType: "text/html"
    };
    check smtpClient->sendMessage(email);
}

# Send an email notifying the update of a repository request.
# 
# + updatedRequest - repository request object
# + return - error
public function updateRepoRequestMail(Request updatedRequest) returns error? {
    string templatePath = "resources/email_templates/update_request.html";
    string emailBody = check createEmailBody(updatedRequest,templatePath);
    string[] ccList = regex:split(updatedRequest.ccList, ",");
    email:Message email = {
        to: [updatedRequest.lead_email,updatedRequest.email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${updatedRequest.id}]`,
        body: emailBody,
        'from: emailConfig.username,
        sender: emailConfig.username,
        replyTo: [],
        contentType: "text/html"
    };
    check smtpClient->sendMessage(email);
}
    
# Send an email notifying the comment on a repository request.
# 
# + request - comment object
# + return - error
public function commentRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/comment_request.html";
    string[] ccList = regex:split(request.ccList, ",");
    string emailBody = check createEmailBody(request,templatePath);
    email:Message email = {
        to: [request.email,request.lead_email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: emailBody,
        'from: emailConfig.username,
        sender: emailConfig.username,
        replyTo: [],
        contentType: "text/html"
};
    check smtpClient->sendMessage(email);
}

# Send an email notifying the approval of a repository request.
# 
# + request - repository request object
# + return - error
public function approveRepoRequestMail(Request request) returns error? {
    string templatePath = "resources/email_templates/approve_request.html";
    string emailBody = check createEmailBody(request,templatePath);
    string[] ccList = regex:split(request.ccList, ",");
    email:Message email = {
        to: [request.email,request.lead_email],
        cc: ccList,
        bcc: [],
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        body: emailBody,
        'from: emailConfig.username,
        sender: emailConfig.username,
        replyTo: [],
        contentType: "text/html"
};
    check smtpClient->sendMessage(email);
}