# Automated GitHub Repository Creator v2

![Ballerina](https://img.shields.io/badge/Ballerina-00ADD8?style=flat&logo=ballerina&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)
![REST API](https://img.shields.io/badge/REST-02569B?style=flat&logo=rest&logoColor=white)
![SMTP](https://img.shields.io/badge/SMTP-FF4B4B?style=flat&logo=gmail&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=flat&logo=visual-studio-code&logoColor=white)


## Overview
The **Automated GitHub Repository Creator v2** is a Ballerina-based application designed to automate the process of creating and managing GitHub repositories. It provides a RESTful API to handle repository requests, automate repository creation, and manage repository configurations such as labels, topics, branch protection, and team permissions.

---

## Features
- **Repository Request Management**:
  - Create, update, delete, and retrieve repository requests.
- **Automated GitHub Repository Creation**:
  - Automatically create repositories in GitHub with predefined configurations.
- **Repository Configuration**:
  - Add labels, topics, issue templates, pull request templates, and branch protection rules.
- **Team Management**:
  - Assign teams with specific permissions to repositories.
- **Email Notifications**:
  - Notify users via email about repository request creation, updates, approvals, and comments.

---

## Technologies Used
- **Ballerina**: The primary programming language for building the application.
- **MySQL**: Used as the database for storing repository requests.
- **GitHub API**: For interacting with GitHub to create and configure repositories.
- **SMTP**: For sending email notifications.

---

## Setup Instructions

### Prerequisites
1. Install [Ballerina](https://ballerina.io/downloads/).
2. Install MySQL and set up a database.
3. Configure a GitHub Personal Access Token (PAT) with the required permissions.
4. Set up an SMTP server for email notifications.

### Configuration
1. Create a `config.toml` file in the root directory.
2. Add the following configuration details:

```toml
[ballerina_crud_application.database.dbConfig]
user = "root"
password = "root"
host = "localhost"
port = 3306
database = "repository_db"

[ballerina_crud_application.emailConfig]
smtpHost = "smtp.gmail.com"
smtpPort = 587
username = "your-email@gmail.com"
password = "your-email-password"
fromAddress = "your-email@gmail.com"
```

### Database Setup
1. Create a MySQL database named `repository_db`.
2. Use the following schema to create the `repository_requests` table:

```sql
CREATE TABLE repository_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255),
    lead_email VARCHAR(255),
    requirement TEXT,
    cc_list TEXT,
    repo_name VARCHAR(255),
    organization VARCHAR(255),
    repo_type VARCHAR(50),
    description TEXT,
    enable_issues BOOLEAN,
    website_url VARCHAR(255),
    topics TEXT,
    pr_protection VARCHAR(50),
    teams TEXT,
    enable_triage_wso2all BOOLEAN,
    enable_triage_wso2allinterns BOOLEAN,
    disable_triage_reason TEXT,
    cicd_requirement VARCHAR(50),
    jenkins_job_type VARCHAR(50),
    jenkins_group_id VARCHAR(50),
    azure_devops_org VARCHAR(255),
    azure_devops_project VARCHAR(255),
    timestamp DATETIME,
    approval_state VARCHAR(50),
    comments TEXT,
    email_thread_id VARCHAR(255)
);
```

# How to Run

Build the Project:
```bal
bal buid
```
Run the Application:
```bal
bal run 
```

The application will start a RESTful API server on http://localhost:9090.

# API Endpoints

### Repository Requests 
* GET /repository_requests: Retrieve all repository requests (filter by member_email or lead_email).
* GET /repository_requests/{id}: Retrieve a specific repository request by ID.
* POST /repository_requests: Create a new repository request.
* PATCH /repository_requests/{id}: Update a repository request by ID.
* PATCH /repository_requests/{id}/comments: Update comments for a repository request.
* PATCH /repository_requests/{id}/approve: Approve a repository request and create the repository on GitHub.
* DELETE /repository_requests/{id}: Delete a repository request by ID.

Modules
1. database
Handles database operations such as inserting, updating, retrieving, and deleting repository requests.

2. email
Manages email notifications for repository request creation, updates, approvals, and comments.

3. gh
Interacts with the GitHub API to create repositories, add labels, topics, templates, branch protection, and manage teams.


### future steps

robust error handling

keep LabelList in a separatre file

keep template content is a separate file

databse module import in email module