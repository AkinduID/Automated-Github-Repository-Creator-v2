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
# + keyValPairs - parameter description  
# + templatePath - parameter description
# + return - return value description
public function createEmailBody(map<string> keyValPairs, string templatePath) returns string|error {
    string htmlContent = check io:fileReadString(templatePath);
    string updatedContent = keyValPairs.entries().reduce(
        isolated function(string content, [string, string] keyVal) returns string {
            string:RegExp regex = re `\{\{\s*${keyVal[0]}\s*\}\}`;
            return regex.replaceAll(content, keyVal[1]);
        },
        htmlContent
    );
    return mime:base64Encode(updatedContent).ensureType();
}

public isolated function sendEmail(map<string> keyValPairs, string emailBody) returns error? {
    EmailPayload payload = {
        to: [keyValPairs["email"].toString(),keyValPairs["lead_email"].toString()],
        'from:"noreply-internal-apps-stg@wso2.com",
        cc: regex:split(keyValPairs["ccList"].toString(), ","),
        subject: string `REQUESTING NEW REPOSITORY [#${keyValPairs["id"].toString()}]`,
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