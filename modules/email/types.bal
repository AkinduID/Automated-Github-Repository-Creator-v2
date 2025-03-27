type EmailConfig record {
    string smtpHost;
    int smtpPort;
    string username;
    string password;
    string fromAddress;
};
public type Request record {
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

// public type createRequest record {
//     int id;
//     string email;
//     string lead_email;
//     string requirement;
//     string ccList;
//     string repoName;
//     string organization;
//     string repoType;
//     string description;
//     boolean enableIssues;
//     string? websiteUrl;
//     string topics;
//     string prProtection;
//     string teams;
//     boolean? enableTriageWso2All;
//     boolean? enableTriageWso2AllInterns;
//     string? disableTriageReason;
//     string cicdRequirement;
//     string? jenkinsJobType;
//     string? jenkinsGroupId;
//     string? azureDevopsOrg;
//     string? azureDevopsProject;
//     string timestamp;
// };

// public type updateRequest record {
//     int id;
//     string email;
//     string lead_email;
//     string requirement;
//     string ccList;
//     string[] repoName;
//     string[] organization;
//     string[] repoType;
//     string[] description;
//     boolean[] enableIssues;
//     string?[] websiteUrl;
//     string[] topics;
//     string[] prProtection;
//     string[] teams;
//     boolean[] enableTriageWso2All;
//     boolean[] enableTriageWso2AllInterns;
//     string?[] disableTriageReason;
//     string[] cicdRequirement;
//     string?[] jenkinsJobType;
//     string?[] jenkinsGroupId;
//     string?[] azureDevopsOrg;
//     string?[] azureDevopsProject;
// };

// public type commentRequest record {
//     int id;
//     string email;
//     string lead_email;
//     string ccList;
//     string? comments;
// };

// public type approveRequest record {
//     int id;
//     string email;
//     string lead_email;
//     string ccList;
//     string repoName;    
//     string organization;
// };