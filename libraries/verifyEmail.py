from imap_tools import MailBox
from imap_tools import AND
from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import re

#Python function for if the respone will gome back as html format
def get_email_links_html(email, pwd, subject, inbody, folder='INBOX'):
    with MailBox(host='imap.gmail.com', port=993).login(email, pwd, folder) as mailbox:
        bodies = [msg.html for msg in mailbox.fetch(AND(subject=subject, text=inbody, seen=False), reverse = True)]
    if len(bodies) == 0:
        BuiltIn().fail(f"No unread email with specified criteria was found subject: {subject}, inbody: {inbody}")
    
    soup = BeautifulSoup(str(bodies))
    links = []
    
    for link in soup.findAll('a', attrs={'href': re.compile("^https://")}):
        links.append(link.get('href'))
    if len(links) == 0:
        BuiltIn().fail(f"No urls found in email with specified criteria was found subject: {subject}, inbody: {inbody}")
    
    return links

#Python function for if the respone will gome back as text format
def get_email_links_text(email, pwd, subject, inbody, folder='INBOX'):
    with MailBox(host='imap.gmail.com', port=993).login(email, pwd, folder) as mailbox:
        bodies = [msg.txt for msg in mailbox.fetch(AND(subject=subject, text=inbody, seen=False), reverse = True)]
    if len(bodies) == 0:
        BuiltIn().fail(f"No unread email with specified criteria was found subject: {subject}, inbody: {inbody}")
    
    soup = BeautifulSoup(str(bodies))
    links = []
    
    if len(links) == 0:
        BuiltIn().fail(f"No urls found in email with specified criteria was found subject: {subject}, inbody: {inbody}")
    for link in soup.findAll('a', attrs={'href': re.compile("^https://")}):
        links.append(link.get('href'))

    return links

#function to check if there is an existing email that is unread and contains something in the subject and in the body of the email. 
def verify_email_exist(email, pwd, subject, inbody, folder='INBOX'):
    with MailBox(host='imap.gmail.com', port=993).login(email, pwd, folder) as mailbox:
        bodies = [msg.text for msg in mailbox.fetch(AND(subject=subject, text=inbody, seen=False), reverse = True)]
    if len(bodies) == 0:
        BuiltIn().fail(f"No emails with specified criteria was found subject: {subject}, inbody: {inbody}")
    
    return bodies

def get_email_id(email, pwd, subject, inbody, folder='INBOX'):
    with MailBox(host='imap.gmail.com', port=993).login(email, pwd, folder) as mailbox:
        msgid = [msg.uid for msg in mailbox.fetch(AND(subject=subject, text=inbody, seen=False), reverse = True)]
    if len(msgid) == 0:
        BuiltIn().fail(f"No emails with specified criteria was found subject: {subject}, inbody: {inbody}")
    
    return msgid