// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import ballerina/io;

configurable string resourcePath = ?;

# Create a github client object.
#
# + githubPAT - Github personal access token
# + return - Github client
public isolated function createGithubClient(string githubPAT)
    returns http:Client|error {

    io:println("Accessing createGithubClient() function");
    http:Client githubClient = check new ("https://api.github.com", {
        auth: {
            token: githubPAT
        }
    });
    return githubClient;
}