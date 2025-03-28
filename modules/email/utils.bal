import ballerina/io;
import ballerina/regex;
import ballerina/email;

# Return html content of the email body
#
# + request - request object 
# + templatePath - path to the email template
# + return - html content of the email body or error
public function createEmailBody(Request request,string templatePath) returns string|error {
    string htmlContent = check io:fileReadString(templatePath);

    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.id \\}\\}", request.id.toString());
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.email \\}\\}", request.email);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.lead_email \\}\\}", request.lead_email);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.ccList \\}\\}", request.ccList);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.requirement \\}\\}", request.requirement);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.repoName \\}\\}", request.repoName);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.organization \\}\\}", request.organization);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.repoType \\}\\}", request.repoType);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.description \\}\\}", request.description);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.enableIssues \\}\\}", request.enableIssues.toString());
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.websiteUrl \\}\\}",request.websiteUrl is string ? request.websiteUrl.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.topics \\}\\}", request.topics);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.prProtection \\}\\}", request.prProtection);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.teams \\}\\}", request.teams);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.enableTriageWso2All \\}\\}", request.enableTriageWso2All.toString());
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.enableTriageWso2AllInterns \\}\\}", request.enableTriageWso2AllInterns.toString());
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.disableTriageReason \\}\\}", request.disableTriageReason is string ? request.disableTriageReason.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.cicdRequirement \\}\\}", request.cicdRequirement);
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.jenkinsJobType \\}\\}", request.jenkinsJobType is string ? request.jenkinsJobType.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.jenkinsGroupId \\}\\}", request.jenkinsGroupId is string ? request.jenkinsGroupId.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.azureDevopsOrg \\}\\}", request.azureDevopsOrg is string ? request.azureDevopsOrg.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.azureDevopsProject \\}\\}", request.azureDevopsProject is string ? request.azureDevopsProject.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.comments \\}\\}", request.comments is string ? request.comments.toString() : "N/A");
    htmlContent = regex:replaceAll(htmlContent, "\\{\\{ request.timestamp \\}\\}", request.timestamp.toString());
    return htmlContent;
}

# Send mail using SMTP client
#
# + request - request object 
# + emailBody - html content of the email body
# + return - error
public function sendEmail(Request request, string emailBody) returns error?{
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