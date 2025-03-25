import ballerina/email;

configurable EmailConfig emailConfig = ?;

email:SmtpConfiguration smtpConfig = {
    port: emailConfig.smtpPort,
    security: email:START_TLS_ALWAYS
};

email:SmtpClient smtpClient = check new (
    emailConfig.smtpHost, 
    emailConfig.username, 
    emailConfig.password, 
    smtpConfig
);