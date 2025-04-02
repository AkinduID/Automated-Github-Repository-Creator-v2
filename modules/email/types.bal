// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

public type repositoryRequest record {
    int id;
    string email;
    string lead_email;
    string requirement;
    string ccList;
    string repoName;
    string organization;
    string repoType;
    string description;
    boolean enableIssues;
    string? websiteUrl;
    string topics;
    string prProtection;
    string teams;
    boolean? enableTriageWso2All;
    boolean? enableTriageWso2AllInterns;
    string? disableTriageReason;
    string cicdRequirement;
    string? jenkinsJobType;
    string? jenkinsGroupId;
    string? azureDevopsOrg;
    string? azureDevopsProject;
    string|null comments;
    string timestamp;
};

public type EmailPayload record {
    # Recipient email(s) as string array
    string[] to;
    # Sender email
    string 'from;
    # Email subject
    string subject;
    # Email template
    string template;
    # CC'ed recipient email(s) as string array
    string[] cc?;
    # BCC'd recipient email(s)
    string[] bcc?;
};