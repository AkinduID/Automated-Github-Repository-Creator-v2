// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/io;
import ballerina/regex;
import ballerina/http;
import ballerina/log;
import ballerina/mime;

// TODO: Test the new function.

# Description.
#
# + request - parameter description  
# + templatePath - parameter description
# + return - return value description
public function createEmailBody(repositoryRequest request, string templatePath) returns string|error {
    string htmlContent = check io:fileReadString(templatePath);
    map<string> keyValPairs = {
        "request.id": request.id.toString(),
        "request.email": request.email,
        "request.lead_email": request.lead_email,
        "request.ccList": request.ccList,
        "request.requirement": request.requirement,
        "request.repoName": request.repoName,
        "request.organization": request.organization,
        "request.repoType": request.repoType,
        "request.description": request.description,
        "request.enableIssues": request.enableIssues.toString(),
        "request.websiteUrl": request.websiteUrl is string ? request.websiteUrl.toString() : "N/A",
        "request.topics": request.topics,
        "request.prProtection": request.prProtection,
        "request.teams": request.teams,
        "request.enableTriageWso2All": request.enableTriageWso2All.toString(),
        "request.enableTriageWso2AllInterns": request.enableTriageWso2AllInterns.toString(),
        "request.disableTriageReason": request.disableTriageReason is string ? request.disableTriageReason.toString() : "N/A",
        "request.cicdRequirement": request.cicdRequirement,
        "request.jenkinsJobType": request.jenkinsJobType is string ? request.jenkinsJobType.toString() : "N/A",
        "request.jenkinsGroupId": request.jenkinsGroupId is string ? request.jenkinsGroupId.toString() : "N/A",
        "request.azureDevopsOrg": request.azureDevopsOrg is string ? request.azureDevopsOrg.toString() : "N/A",
        "request.azureDevopsProject": request.azureDevopsProject is string ? request.azureDevopsProject.toString() : "N/A",
        "request.comments": request.comments is string ? request.comments.toString() : "N/A",
        "request.timestamp": request.timestamp.toString()
    };
    string updatedContent = keyValPairs.entries().reduce(
        isolated function(string content, [string, string] keyVal) returns string {
            string:RegExp regex = re `\{\{\s*${keyVal[0]}\s*\}\}`;
            return regex.replaceAll(content, keyVal[1]);
        },
        htmlContent
    );
    return mime:base64Encode(updatedContent).ensureType();
}

public isolated function sendEmail(repositoryRequest request, string emailBody) returns error? {
    EmailPayload payload = {
        to: [request.email,request.lead_email],
        'from:"noreply-internal-apps-stg@wso2.com",
        cc: regex:split(request.ccList, ","),
        subject: string `REQUESTING NEW REPOSITORY [#${request.id}]`,
        template: emailBody
    };
    http:Response|http:ClientError response = emailClient->/send\-email.post(payload);
    if response is http:ClientError {
        string customError = string `Client Error occurred while sending the email !`;
        log:printError(customError, response);
        return error(customError);
    }
    if response.statusCode != http:STATUS_OK {
        string customError = string `Error occurred while sending the email !`;
        log:printError(string `${customError} : ${(check response.getJsonPayload()).toJsonString()}!`);
        return error(customError);
    }
    log:printInfo(string `Email sent successfully to ${payload.to.toString()}`);
}