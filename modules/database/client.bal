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