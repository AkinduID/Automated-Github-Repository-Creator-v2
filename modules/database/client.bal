// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable DatabaseConfig dbConfig = ?;


final mysql:Client dbClient = check new (
    user = dbConfig.user,
    password = dbConfig.password,
    database = dbConfig.database,
    host = dbConfig.host,
    port = dbConfig.port,
    options = {
        ssl: {
            mode: dbConfig.sslMode, // Set the desired SSL mode
            allowPublicKeyRetrieval: true
        }
    } 
);