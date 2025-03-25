import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import make_msgid
from dotenv import load_dotenv
import os
import datetime

load_dotenv()

sender_email = os.getenv("SENDER_EMAIL")
reciever_email = os.getenv("RECIEVER_EMAIL")
sender_password = os.getenv("SENDER_PASSWORD")
smtp_server = os.getenv("SMTP_SERVER")
smtp_port = os.getenv("SMTP_PORT")

def setup_email(msg, payload,email_thread_id=None):
    email_message_id = make_msgid()
    dt = datetime.datetime.fromisoformat(payload['timestamp'])
    short_timestamp = dt.strftime("%Y-%m-%d %H:%M")
    msg['From'] = sender_email
    msg['To'] = reciever_email #payload["lead_email"]
    msg['Cc'] = payload["cc_list"]
    msg['Subject'] = f"Requesting New Github Repository [{short_timestamp}]"
    if email_thread_id:
        msg['In-Reply-To'] = email_thread_id
        msg['References'] = email_thread_id
    msg['Message-ID'] = email_message_id
    return msg, email_message_id

def email_body(payload):
    return f"""
    Requested By: {payload['email']}
    Requesting From: {payload['lead_email']}
    Requirement: {payload['requirement']}

    Repository Details
    Repository Name: {payload['repo_name']}
    Organization: {payload['organization']}
    Description: {payload['description']}
    Website URL: {payload['website_url']}
    Topics: {', '.join(payload['topics'])}
    Enable Issues: {payload['enable_issues']}

    Security Details
    PR Protection Enabled: {payload['pr_protection']}
    Teams to be added:
    {', '.join(payload['teams'])}
    Enable Triage for WSO2 All: {payload['enable_triage_wso2all'] if payload['organization'] == "gitopslab-enterprise" else "Not Applicable"}
    Enable Triage for WSO2 All Interns: {payload['enable_triage_wso2allinterns'] if payload['organization'] == "gitopslab-enterprise" else "Not Applicable"}
    Disable Triage Reason: {payload['disable_triage_reason'] if payload['organization'] == "gitopslab-enterprise" else "Not Applicable"}

    Devops Details
    CICD Requirement: {payload['cicd_requirement']}
    Jenkins Job Type: {payload['jenkins_job_type'] if payload['cicd_requirement'] == "Jenkins" else "Not Applicable"}
    Jenkins Group ID: {payload['jenkins_group_id'] if payload['cicd_requirement'] == "Jenkins" else "Not Applicable"}
    Azure DevOps Organization: {payload['azure_devops_org'] if payload['cicd_requirement'] == "Azure DevOps" else "Not Applicable"}
    Azure DevOps Project: {payload['azure_devops_project'] if payload['cicd_requirement'] == "Azure DevOps" else "Not Applicable"}

    """

def send_email(msg, to_addr):
    """
    Sends an email using the provided message and recipient addresses.

    Args:
        msg (MIMEMultipart): The email message to be sent.
        to_addr (list): List of recipient email addresses.
    """
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, to_addr, text)
        server.quit()
        print("Email sent successfully!")
    except Exception as e:
        print(f"Error sending email: {e}")

def create_request_email(payload):
    """
    Creates and sends an email for a new GitHub repository request.

    Args:
        payload (dict): Dictionary containing the request details.

    Returns:
        str: The email thread ID.
    """
    msg = MIMEMultipart()
    msg, email_thread_id = setup_email(msg,payload)
    body = f"""
    Hi,
    This is a request for creating a new GitHub repository as part of the automated system testing.
    {email_body(payload)}
    """

    msg.attach(MIMEText(body, 'plain'))
    to_addr = [reciever_email] + payload["cc_list"].split(",")
    send_email(msg, to_addr)
    return email_thread_id

def update_request_email(payload, email_thread_id):
    """
    Creates and sends an email to update a previous GitHub repository request.

    Args:
        payload (dict): Dictionary containing the updated request details.
        email_thread_id (str): The email thread ID of the original request.
    """
    msg = MIMEMultipart()
    setup_email(msg, payload, email_thread_id)
    body = f"""
    Hi,
    This is an update on the previous request for creating a new GitHub repository.
    {email_body(payload)}
    """

    msg.attach(MIMEText(body, 'plain'))
    to_addr = [reciever_email] + payload["cc_list"].split(",")
    send_email(msg, to_addr)

def comment_request_email(payload, email_thread_id):
    """
    Creates and sends an email to comment on a previous GitHub repository request.

    Args:
        payload (dict): Dictionary containing the comment details.
        email_thread_id (str): The email thread ID of the original request.
    """
    msg = MIMEMultipart()
    setup_email(msg, payload, email_thread_id)
    body = f"""
    Hi,
    This is a comment on your request for creating a new GitHub repository.
    {payload['comments']}
    Please review and update your request accordingly.
    """

    msg.attach(MIMEText(body, 'plain'))
    to_addr = [reciever_email] + payload["cc_list"].split(",")
    send_email(msg, to_addr)

def approve_request_email(payload, email_thread_id):
    """
    Creates and sends an email to approve a GitHub repository request.

    Args:
        payload (dict): Dictionary containing the approval details.
        email_thread_id (str): The email thread ID of the original request.
    """
    msg = MIMEMultipart()
    setup_email(msg, payload, email_thread_id)
    body = f"""
    Hi,
    Your request for creating a new GitHub repository has been approved.
    Repository Link: https://github.com/{payload["organization"]}/{payload["repo_name"]}
    DevOps Configurations will be handled by DigiOps Team Manually.
    """

    msg.attach(MIMEText(body, 'plain'))
    to_addr = [reciever_email] + payload["cc_list"].split(",")
    send_email(msg, to_addr)


# if __name__ == "__main__":
#     payload =  {
#         "email": "hello@g.com",
#         "lead_email": "helloadmin@g.com",
#         "requirement": "cc",
#         "cc_list": "akii.dell.100@gmail.com",
#         "repo_name": "EMAIL_TEST",
#         "organization": "gitopslab",
#         "repo_type": False,
#         "description": "cc",
#         "enable_issues": True,
#         "website_url": "",
#         "topics": [
#             ""
#         ],
#         "pr_protection": True,
#         "teams": [
#             "a-internal-commiters"
#         ],
#         "enable_triage_wso2all": False,
#         "enable_triage_wso2allinterns": False,
#         "disable_triage_reason": "",
#         "cicd_requirement": "Not Applicable",
#         "jenkins_job_type": "",
#         "jenkins_group_id": "",
#         "azure_devops_org": "",
#         "azure_devops_project": "",
#         "timestamp": "2025-03-04T10:36:29.858240",
#         "approval_state": "Pending",
#         "comments": "",
#         "email_thread_id": "<174106838985.41140.6395963164442515735@akindu.local>"
#     }
#     email_thread_id = create_request_email(payload)
#     update_request_email(payload, email_thread_id)
#     comment_request_email(payload, email_thread_id)
#     approve_request_email(payload, email_thread_id)