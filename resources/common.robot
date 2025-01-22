*** Settings ***
Library                         QForce
Library                         QWeb
Library                         String
Library                         DateTime


*** Variables ***
${browser}                      chrome

${username}                     hvisser@copado.com.crt
${login_url}                    https://slockard-dev-ed.lightning.force.com/
${home_url}                     ${login_url}/lightning/page/home
${applauncher}                  //*[contains(@class, "appLauncher")]

${company}                      ExampleCorp
${accountName}                  ExamplaryBranch
${first}                        Demo
${last}                         McTest
${email}                        DTest@test.test
${phone}                        1234567890

${demoFirst}                    Marty
${demoLast}                     McFly

*** Keywords ***
Setup Browser
    [Arguments]                 ${url}=about:blank          ${browser}=chrome
    Set Library Search Order    QWeb                        QForce
    Open Browser                ${url}                      ${browser}
    SetConfig                   LineBreak                   ${EMPTY}                    #\ue000
    SetConfig                   DefaultTimeout              30s                         #sometimes salesforce is slow
    Evaluate                    random.seed()               random                      # initialize random generator
    SetConfig                   Delay                       0.3                         # adds a delay of 0.3 between keywords. This is helpful in cloud with limited resources.

Form Fill
    [Documentation]             This requests a demo
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     United States
End suite
    Close All Browsers

Form fill demo
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    DropDown                    Employee Size*              1-2,500
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     Netherlands

Form Fill Training
    [Documentation]             This keyword was generated during the training and can be used to fill in the form on the copado website
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    DropDown                    Employee Size*              1-2,500
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     Netherlands

Login
    [Documentation]             Login to Salesforce instance
    GoTo                        ${login_url}
    TypeText                    Username                    ${username}
    TypeText                    Password                    ${password}
    ClickText                   Log In
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}                ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

Setup       
    GoTo                        ${login_url}lightning/setup/SetupOneHome/home

Home
    [Documentation]             Navigate to homepage, login if needed
    End suite
    Setup Browser
    GoTo                        ${home_url}
    ${login_status}=            IsText                      To access this page, you have to log in to Salesforce.                              5
    Run Keyword If              ${login_status}             Login
    VerifyText                  Home

InsertRandomValue
    [Documentation]             This keyword accepts a character count, suffix, and prefix.
    ...                         It then types a random string into the given field.
    ...                         This is an example of generating dynamic data within a test
    ...                         and how to create a keyword with optional/default arguments.
    [Arguments]                 ${field}                    ${charCount}=5              ${prefix}=                  ${suffix}=
    Set Library Search Order    QWeb
    ${testRandom}=              Generate Random String      ${charCount}
    TypeText                    ${field}                    ${prefix}${testRandom}${suffix}


VerifyNoAccounts
    VerifyNoText                ${accountName}              timeout=3


DeleteData
    [Documentation]             RunBlock to remove all data until it doesn't exist anymore
    ClickText                   ${accountName}
    ClickText                   Show more actions
    ClickText                   Delete
    VerifyText                  Are you sure you want to delete this account?
    # ClickText                 Delete                      2
    ClickText                   Delete
    VerifyText                  Undo
    VerifyNoText                Undo
    ClickText                   Accounts                    partial_match=False


Cleanup                   
    Login
    Sleep                       3
    LaunchApp                   Sales
    ClickText                   Accounts
    RunBlock                    VerifyNoAccounts            timeout=180s                exp_handler=DeleteData
    Sleep                       3

MFA Login
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}                ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

ExampleKey
    ClickText                   New
    UseModal                    On
    ClickText                   Account Name
    TypeText                    Account Name                App
    PickList                    Account Currency            USD - U.S. Dollar
    ClickText                   Save                        anchor=SaveEdit
    UseModal                    Off

Login_with_another_user
    [Documentation]             Login to Salesforce instance
    [Arguments]                 ${username}                 ${password}
    End suite
    Setup Browser
    GoTo                        ${login_url}
    TypeText                    Username                    ${username}
    TypeText                    Password                    ${password}
    ClickText                   Log In
    ${isMFA}=                   IsText                      Login Approval Required     #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${secret_hidde}             ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

Commonfunction
    ClickText                   Opportunities
    ClickText                   New
    UseModal                    On
    ClickText                   Complete this field.
    TypeText                    Close Date                  12/1/2022

    ClickText                   Complete this field.
    TypeText                    *Opportunity Name           Hidde BV
    ClickText                   Save                        partial_match=False
    PickList                    *Stage                      Prospecting
    ClickText                   Save                        partial_match=False
    UseModal                    Off

    ClickText                   View profile
    VerifyText                  TEST ROBOT
    ClickText                   Log Out

Login As
    [Documentation]             Login As different persona. User needs to be logged into Salesforce with Admin rights
    ...                         before calling this keyword to change persona.
    ...                         Example:
    ...                         LoginAs                     Chatter Expert
    [Arguments]                 ${persona}
    ClickText                   Setup
    ClickText                   Setup for current app
    SwitchWindow                NEW
    TypeText                    Search Setup                ${persona}                  delay=2
    ClickText                   User                        anchor=${persona}           delay=5                     # wait for list to populate, then click
    VerifyText                  Freeze                      timeout=45                  # this is slow, needs longer timeout
    ClickText                   Login                       anchor=Freeze               delay=1

Global search and select type
    [Documentation]             searching and navigating to name with specific type
    [Arguments]                 ${name}                     ${type}
    ClickText                   Search...
    # ClickElement              //button[contains(@aria-label,'Search')]
    TypeText                    Search...                   ${name}
    Clickelement                //span[contains(@title,'${name}')]/ancestor::div[@class\='instant-results-list']//span[contains(text(),'${type}')]

Determine Login Strategy
    [Arguments]                 ${provided_username}=${None}                            ${provided_password}=${None}                            ${browser}=chrome
    ${DYNAMIC_LOGIN}=           Get Variable Value          ${loginUrl}                 NoValuePassed
    Log                         ${DYNAMIC_LOGIN}            console=true

    IF                          '${DYNAMIC_LOGIN}' == 'NoValuePassed'
        Set Global Variable     ${loginUrl}                 ${url}                      # CRT local
    END

    # CI/CD sysadmin: This condition is met if ${loginUrl} is provided but neither ${username} nor ${password} is provided. This suggests a scenario where a login URL is enough for access, typically for admin or generic system access without specific user credentials. Once executed, tests can use login as.
    # User Login provided by test: This condition is met if ${loginUrl}, ${username}, and ${password} are all provided. This indicates that specific user credentials are required for login, which is typical for user-specific authentication processes.
    # Default User CRT local: This is the default or fallback condition if neither of the above conditions is met. It covers scenarios where either the ${loginUrl} is not provided or one of the ${username} or ${password} is missing, suggesting a local or development environment where the login might be handled differently or with different credentials.
    # ${loginStrategy}=         Evaluate                    'CI/CD sysadmin' if ${loginUrl} and 'frontdoor' in ${loginUrl} else ('User Login' if '${loginUrl}' and '${provided_username}' and '${provided_password}' else 'CRT local')
    ${loginStrategy}=           Evaluate                    'CI/CD sysadmin' if '${loginUrl}' and 'frontdoor' in '${loginUrl}' and '${provided_username}' == 'None' and '${provided_password}' == 'None' else ('User Login' if '${loginUrl}' and '${provided_username}' != 'None' and '${provided_password}' != 'None' else 'CRT local')
    Log                         Selected login strategy: ${loginStrategy}               console=true

    Run Keyword If              '${loginStrategy}' == 'CI/CD sysadmin'                  CI/CD Sysadmin Login        ${loginUrl}                 ${browser}
    Run Keyword If              '${loginStrategy}' == 'User Login'                      User Login                  ${loginUrl}                 ${provided_username}      ${provided_password}    ${browser}
    Run Keyword If              '${loginStrategy}' == 'CRT local'                       CRT Local Login             ${loginUrl}                 ${username}               ${password}    ${browser}

CI/CD Sysadmin Login
    [Arguments]                 ${loginUrl}                 ${browser}
    Log                         Logging in as CI/CD sysadmin...

    Setup Browser               ${loginUrl}                 ${browser}
    ${url}=                     Get Base URL                ${loginUrl}
    Set Global Variable         ${url}                      ${url}

User Login
    [Arguments]                 ${loginUrl}                 ${username}                 ${password}                 ${browser}                  ${mfa_secret}=${EMPTY}
    Set Library Search Order    QForce                      QWeb
    Log                         Logging in as user...

    ${base_url}=                Get Base URL                ${loginUrl}
    Setup Browser               ${base_url}                 ${browser}
    TypeText                    Username                    ${username}
    TypeSecret                  Password                    ${password}
    ClickText                   Log In

    IF                          "${mfa_secret}" != "${EMPTY}"
        ${mfa_code}=            GetOTP                      ${username}                 ${mfa_secret}
        TypeSecret              Verification Code           ${mfa_code}
        ClickText               Verify
    END

CRT Local Login
    [Arguments]                 ${loginUrl}                 ${username}                 ${password}                 ${browser}                  ${mfa_secret}=${EMPTY}
    Set Library Search Order    QForce                      QWeb
    Log                         Logging in locally for CRT...


    # Assuming ${url} is configured on robot variables.
    Setup Browser               ${loginUrl}                 ${browser}
    TypeText                    Username                    ${username}
    TypeSecret                  Password                    ${password}
    ClickText                   Log In

    IF                          "${mfa_secret}" != "${EMPTY}"
        ${mfa_code}=            GetOTP                      ${username}                 ${mfa_secret}
        TypeSecret              Verification Code           ${mfa_code}
        ClickText               Verify
    END

Get Base URL
    [Arguments]                 ${loginUrl}
    # ${loginUrl} passed by CI/CD contains by default an authenticated token: https://xxxxx.sandbox.xxx.xxxxx.com/more/more/token?=xa123123dsadasd
    # As we don't want to use the token to login, we need to retrieve the base url to enter the login screen.
    ${parts}=                   Split String                ${loginUrl}                 /
    ${base_url}=                Set Variable                ${parts[0]}//${parts[2]}
    RETURN                      ${base_url}