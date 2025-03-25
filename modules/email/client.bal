import ballerina/email;

configurable EmailConfig emailConfig = ?;

email:SmtpConfiguration smtpConfig = {
    port: emailConfig.smtpPort
};

email:SmtpClient smtpClient = check new (
    emailConfig.smtpHost, 
    emailConfig.username, 
    emailConfig.password, 
    smtpConfig
);