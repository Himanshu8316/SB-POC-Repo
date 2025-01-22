*** Settings ***
Library                         QForce
Library                         QWeb
Library                         DateTime
Library                         Collections
Library                         ../libraries/smtp.py
Library                         ../libraries/verifyEmail.py
Resource                        ../resources/common.robot
Library                         OperatingSystem
Suite Setup                     OpenBrowser                 About:blank                 Chrome
Suite Teardown                  CloseAllBrowsers


*** Variables ***
# Test Data Send Email and Validate case creation####
${EMAIL_SUBJECT}                ${EMPTY}
${EMAIL_BODY}                   ${EMPTY}
${EMAIL_ADDRESS}                growthpoint@28cudlou7e5c1yojk49gfnckto6xqn2qvimb3wfb668qhiad2q.by-blhyiua1.deu114s.apex.sandbox.salesforce.com
${CUSTOMER_EMAIL}               poc01162025@gmail.com
${APPPASSGMAIL}                 icad jpdp xnop zrpx
${RESPONSE_EMAIL_SUBJECT}       ${EMPTY}
${RESPONSE_EMAIL_BODY}          ${EMPTY}

*** Test Cases ***
Send Email and Validate case creation
    # Customer sending email to SB
    ${timestamp}=               Get Current Date
    ${EMAIL_SUBJECT}=           Set Variable                Test Case Creation${timestamp}
    ${EMAIL_BODY}=              Set Variable                This is a test email for case creation${timestamp}
    Send Email                  ${EMAIL_SUBJECT}            ${EMAIL_BODY}               ${CUSTOMER_EMAIL}      ${EMAIL_ADDRESS}            ${CUSTOMER_EMAIL}           ${APPPASSGMAIL}

    #Verify the case creation in SF sandbox
    Goto                        ${loginUrl}
    TypeText                    username                    ${username}
    TypeText                    password                    ${password}
    ClickText                   Log In to Sandbox
    ${MFA_needed}=              Run Keyword And Return Status                           Should Not Be Equal    ${None}                     ${MY_SECRET}
    Log To Console              ${MFA_needed} # When given ${MFA_needed} is true, see Log to Console keyword result
    IF                          ${MFA_needed}
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}
        TypeSecret              Verification Code           ${mfa_code}
        ClickText               Verify
    END
    VerifyText                  Sandbox: CHNWSIT            timeout=30s
    # Searching the new case created
    Sleep                       5s
    WHILE                       True
        GlobalSearch            ${loginUrl}                 ${EMAIL_SUBJECT}            case
        sleep                   1s
        ${case}                 IsText                      No results for "${EMAIL_SUBJECT}" in               partial_match=flase
        Log To Console          ${case}
        IF                      ${case}
            CONTINUE
        ELSE
            ClickText           ${EMAIL_SUBJECT}            anchor=Subject
            BREAK
        END
    END
    # Validating the new case created
    # VerifyText                Email                       anchor=Case Origin
    VerifyField                 Web Email                   ${CUSTOMER_EMAIL}           tag=a                  partial_match=True
    VerifyField                 Case Record Type            Service Request             partial_match=True
    ${casenumber}               getfieldvalue               Case Number
    Log To Console              ${casenumber}

    # Verify the response Email Exist in customer inbox
    [Documentation]             Check if unread email exist based on something in the subject and body
    ${RESPONSE_EMAIL_SUBJECT}=                              Set Variable                Sandbox01: ${EMAIL_SUBJECT} ${casenumber}
    ${RESPONSE_EMAIL_BODY}=     Set Variable                Your Reference Number for this query is ${casenumber}.
    ${test}=                    Verify Email Exist          email=${CUSTOMER_EMAIL}     pwd=${APPPASSGMAIL}    subject=${RESPONSE_EMAIL_SUBJECT}                       inbody=${RESPONSE_EMAIL_BODY}
