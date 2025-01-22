*** Settings ***
Library                 QWeb
Library                 QForce
Library                 RequestsLibrary
Library                 Collections
Library                 DateTime
Suite Setup             OpenBrowser                 About:blank                 Chrome
Suite Teardown          CloseAllBrowsers

*** Test Cases ***
Execute Batch Job
    SetConfig           DefaultTimeout              20s
    #Login to SF sandbox
    Goto                ${loginUrl}
    TypeText            username                    ${username}
    TypeText            password                    ${password}
    ClickText           Log In to Sandbox
    ${MFA_needed}=      Run Keyword And Return Status                           Should Not Be Equal                   ${None}    ${MY_SECRET}
    Log To Console      ${MFA_needed} # When given ${MFA_needed} is true, see Log to Console keyword result
    IF                  ${MFA_needed}
        ${mfa_code}=    GetOTP                      ${username}                 ${MY_SECRET}
        TypeSecret      Verification Code           ${mfa_code}
        ClickText       Verify
    END
    VerifyText          Sandbox: CHNWSIT            timeout=30s

    # Running Batch Job
    ClickText           Setup
    ClickText           Developer Console
    SwitchWindow        NEW
    ClickText           Debug
    ClickText           CTRL+E
    WriteText           CMN_BATCH_AccountMaintenance.run(100);
    ClickText           Execute
    ${Executiontime}    Get Current Date            result_format=%d/%m/%Y, %H:%M
    Log To Console      ${Executiontime}
    Verifytext          Batch Apex                  anchor=Operation            timeout=40s
    CloseWindow

    # Validating Batch Job Logs
    LaunchApp           Batch Job Logs
    ClickText           Select a List View: Batch Job Logs
    ClickText           All
    # Searching The Batch Job
    ${sortcases}        gettext                     //span[@title\="Batch Job Log No."]/parent::a/following-sibling::span
    Log To Console      ${sortcases}
    IF                  "${sortcases}"=="Sorted Ascending"
        ClickElement    //span[@title\="Batch Job Log No."]
    END
    ClickText           BJL-                        anchor=Batch Job Log No.    partial_match=true
    VerifyField         Batch Job Name              CMN_BATCH_AccountMaintenance                      partial_match=True
    ${batchstatus}      GetFieldValue               Status
    Should Be True      '${batchstatus}' == 'Processing' or '${batchstatus}' == 'Completed'