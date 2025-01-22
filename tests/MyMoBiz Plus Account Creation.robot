*** Settings ***
Library                         QWeb
Library                         DateTime
Library                         FakerLibrary
Library                         BuiltIn
Library                         QVision
Resource                        ../resources/common.resource
Suite Setup                     Setup Browser
Suite Teardown                  CloseAllBrowsers

*** Variables ***
${baseurl}                      https://standardbank--bcwhotfix.sandbox.my.site.com/southafrica/business
${firstname}
${surname}
${idnumber}
# ${phonenumber}                0844662927
${phonenumber}                  0878134515
${email}
${businessname}                 Paty Plex
${businessturnover}             90000
${businessprovince}             LIMPOPO
${privacystatementurl}          https://www.standardbank.co.za/southafrica/personal/about-us/legal/privacy-statement
${username}
${password}                     Test@1234
${generateSAIDurl}              https://chris927.github.io/generate-sa-idnumbers/

*** Test Cases ***
Create MyMoBiz Plus Accounts
    Set Library Search Order    QWeb                        QVision
    SetConfig                   DefaultTimeout              30

    # Generate SA ID Numbers
    GoTo                        ${generateSAIDurl}
    ${random_year}=             Generate Number Between     50                          95
    ${random_month}=            Generate Number Between     1                           12
    IF                          ${random_month}<10
        ${random_month}         Catenate                    SEPARATOR=                  0                   ${random_month}
    END
    ${random_day}=              Generate Number Between     1                           31
    IF                          ${random_day}<10
        ${random_day}           Catenate                    SEPARATOR=                  0                   ${random_day}
    END
    Log To Console              ${random_year}
    Log To Console              ${random_month}
    Log To Console              ${random_day}
    DropDown                    year                        ${random_year}
    DropDown                    month                       ${random_month}
    DropDown                    day                         ${random_day}
    Clickitem                   gender                      Male
    Clickitem                   submit
    ${idnumber}                 GetText                     //div[@id\='result']
    Log To Console              ${idnumber}

    # Generate data
    ${firstname}                First Name
    ${surname}                  Last Name
    ${email}                    Catenate                    SEPARATOR=                  ${firstname}        ${surname}         @gmail.com
    ${randomstring}             Get Current Date            result_format=%m%d%Y%H%M%S
    ${username}                 Catenate                    SEPARATOR=                  ${firstname}        ${randomstring}
    Log To Console              ${username}

    # MyMoBiz Plus Accounts Application
    GoTo                        ${baseurl}
    ClickText                   Accept All Cookies

    # validate color for header RGBA format (HEX #0033a1)
    ${elem}=                    GetWebElement               //section
    Log To Console              ${elem}
    ${background_color}=        Evaluate                    $elem[1].value_of_css_property("background-color")
    Log To Console              ${background_color}
    Should Be Equal             ${background_color}         rgba(0, 51, 161, 1)

    ${elem}=                    GetWebElement               //header//div
    Log To Console              ${elem}
    ${background_color}=        Evaluate                    $elem[1].value_of_css_property("background-color")
    Log To Console              ${background_color}
    Should Be Equal             ${background_color}         rgba(0, 51, 161, 1)
    
    HoverText                   Products and Services
    ClickText                   See all accounts
    VerifyText                  Business bank accounts
    VerifyText                  MyMoBiz Plus Account
    ClickText                   APPLY ONLINE                anchor=1 free immediate payment
    VerifyText                  MyMoBiz Plus Account
    VerifyText                  Before you begin
    VerifyText                  A device with a camera to verify your identity through facial recognition
    Verifytext                  What you can expect
    Verifytext                  Existing Standard Bank customers must sign in, while new
    VerifyText                  customers must register.
    VerifyText                  Steps
    VerifyText                  Verify your business
    VerifyText                  Complete the application
    VerifyText                  Finalise the application
    VerifyText                  Verify your identity
    ClickText                   Continue
    VerifyText                  MYMOBIZ PLUS APPLICATION

    # Enter Individual Details
    TypeText                    Enter your first name       ${firstname}
    TypeText                    Enter your surname          ${surname}
    TypeText                    Enter your ID number        ${idnumber}
    TypeText                    Enter your phone number     ${phonenumber}
    TypeText                    EMAIL ADDRESS               ${email}

    # Enter Company Details
    VerifyText                  Company details
    ClickElement                //input[@data-value\='true'][@name\='soleOwner']
    ClickElement                //input[@data-value\='false'][@name\='companyRegistered']
    ClickElement                //input[@data-value\='true'][@name\='soleShareholder']
    TypeText                    Enter your business name    ${businessname}
    TypeText                    //input[@name\='businessTurnover']                      ${businessturnover}
    ClickElement                //input[@name\='businessProvince']
    ClickText                   ${businessprovince}
    ClickText                   See More

    # validate privacy statement links
    ClickText                   www.standardbank.co.za/privacy
    SwitchWindow                NEW
    VerifyUrl                   ${privacystatementurl}
    VerifyText                  Privacy statement
    VerifyText                  Group Privacy Statement
    CloseWindow
    ClickText                   Privacy statement           partial_match=False
    SwitchWindow                NEW
    VerifyUrl                   ${privacystatementurl}
    VerifyText                  Privacy statement
    VerifyText                  Group Privacy Statement
    CloseWindow

    # Verification
    ClickCheckbox               I have read and understood the contents of the Privacy statement.           on
    ClickText                   continue
    ${retry}                    IsText                      RETRY                       timeout=20s
    Log To Console              ${retry}
    IF                          ${retry}
        ClickText               RETRY
    END
    VerifyText                  Verification Successful     timeout=30s

    # New User registration
    VerifyText                  NEW STANDARD BANK CUSTOMER
    ClickText                   REGISTER
    VerifyText                  Sign in
    SetConfig                   ShadowDOM                   True
    ClickText                   Register                    anchor=Forgot username
    SetConfig                   ShadowDOM                   False
    TypeText                    lipFirstName                ${firstname}
    TypeText                    lipmail                     ${email}
    TypeText                    lipusername                 ${username}
    TypeSecret                  pf.pass                     ${password}
    TypeSecret                  pass-confirm                ${password}
    SetConfig                   ShadowDOM                   True
    ClickText                   NEXT
    SetConfig                   ShadowDOM                   False
    VerifyText                  MYMOBIZ PLUS APPLICATION    timeout=60s

    #Enter Personal Details
    VerifyText                  Personal Details
    TypeText                    Nationality                 SOUTH AFRICA
    ClickElement                //input[@name\='Nationality']
    ClickText                   SOUTH AFRICA
    ClickElement                //input[@data-value\='false'][@data-name\='PublicOfficial']
    ClickElement                //input[@data-value\='false'][@data-name\='Related']
    ClickElement                //input[@data-value\='true'][@data-name\='TaxResident']
    ClickElement                //input[@name\='country']
    ClickText                   Afghanistan : Income Tax Number
    ClickText                   I DON'T HAVE A TAX NUMBER
    ClickElement                //input[@name\='taxReason']
    ClickText                   THE JURISDICTION OF RESIDENCE DOES NOT ISSUE
    ClickItem                   continue                    tag=button

    # Enter Residential Address
    VerifyText                  Residential address
    VerifyText                  Enter your home address here
    TypeText                    e.g 134 Raglan street       325 castle street
    TypeText                    e.g 12                      78
    TypeText                    e.g. Eye of Africa Estate                               Knopy
    TypeText                    e.g Sandton                 south st
    TypeText                    //input[@name\='city']      Johannesburg                anchor=CITY/TOWN
    TypeText                    Please select               EASTERN CAPE
    ClickElement                //input[@name\='province']
    ClickText                   EASTERN CAPE
    TypeText                    e.g 2091                    7862
    ClickText                   continue

    # Enter Company Details
    VerifyText                  MYMOBIZ PLUS APPLICATION
    VerifyText                  Company Details
    VerifyText                  Enter the following information about Paty Plex
    Typetext                    NATURE OF THE BUSINESS      Alternative Medical Service Providers
    ClickElement                //input[@name\='NATURE OF THE BUSINESS']
    ClickText                   Alternative Medical Service Providers
    TypeText                    INDUSTRY CLASSIFICATION     ACCOUNTING, BOOKKEEPING, AUDITING, TAX
    ClickElement                //input[@name\='INDUSTRY CLASSIFICATION']
    ClickText                   ACCOUNTING, BOOKKEEPING, AUDITING, TAX
    TypeText                    PREFERRED BRANCH            ALEX MALL
    ClickElement                //input[@name\='PREFERRED BRANCH']
    ClickText                   ALEX MALL
    TypeText                    COUNTRY OF REGISTRATION     SOUTH AFRICA
    ClickElement                //input[@name\='COUNTRY OF REGISTRATION']
    ClickText                   SOUTH AFRICA
    VerifyText                  B-BBEE details
    TypeText                    ownership                   BLACK COMPANIES 100% OWNED
    ClickElement                //input[@name\='ownership']
    ClickText                   BLACK COMPANIES 100% OWNED
    ClickElement                //input[@data-value\='true'][@data-name\='isCertificateValid']
    TypeText                    beeContributionLevel        2 - 125% Procurement Recognition
    ClickElement                //input[@name\='beeContributionLevel']
    ClickText                   2 - 125% Procurement Recognition
    TypeText                    beeBlackWomanOwnershipPerc                              No black woman ownership
    ClickElement                //input[@name\='beeBlackWomanOwnershipPerc']
    ClickText                   No black woman ownership
    TypeText                    certificateIssueDate        02 Dec 2024
    ClickText                   continue                    anchor=back

    # Company Trading address
    VerifyText                  Company trading address     timeout=60s
    QVision.VerifyText          325 CASTLE STREET, 78, KNOPY, SOUTH ST,
    QVision.VerifyText          JOHANNESBURG, 7862
    ClickText                   continue                    anchor=back

    # Company Financial Details
    VerifyText                  Company financial details                               timeout=60s
    TypeText                    ENTITY CLASSIFICATION       Non-financial Institution
    ClickElement                //input[@name\='ENTITY CLASSIFICATION']
    ClickText                   Non-financial Institution
    ClickElement                //input[@data-value\='true'][@name\='nfiradio']
    ClickElement                //input[@data-value\='true'][@data-name\='FOREIGN TAX RESIDENCY']
    Typetext                    country                     Albania : Income Tax Number
    ClickElement                //input[@name\='country']
    ClickText                   Albania : Income Tax Number
    ClickText                   I DON'T HAVE A TAX NUMBER
    TypeText                    taxReason                   THE JURISDICTION OF RESIDENCE DOES NOT ISSUE TINS
    ClickElement                //input[@name\='taxReason']
    ClickText                   THE JURISDICTION OF RESIDENCE DOES NOT ISSUE TINS
    ClickItem                   BUSINESS FUNDING            tag=input
    ClickText                   Interest received
    # ClickElement              //span[text()\='Interest received']
    ClickText                   (Choose one or more)
    Typetext                    Interest received           787
    ClickItem                   BUSINESS FUNDING            tag=input
    # ClickElement              //span[text()\='Donation']
    ClickText                   Donation
    ClickText                   (Choose one or more)
    TypeText                    Donation                    897
    ClickText                   continue                    anchor=back

    # Marketing Consent
    VerifyText                  Marketing consent           timeout=60s
    ClickElement                //input[@data-value\='true'][@data-name\='consentForSharing']
    ClickElement                //input[@data-value\='true'][@data-name\='consentForMarketing']
    ClickElement                //input[@data-value\='false'][@data-name\='consentForCrossBorderSharing']
    ClickText                   continue                    anchor=back

    # Select card
    VerifyText                  Select your preferred card                              timeout=60s
    ClickText                   SELECT                      anchor=existing cover at a preferential rate
    ${bankbranch}               Istext                      Standard Bank branch (free)
    IF                          ${bankbranch}
        ClickItem               Standard Bank branch        tag=input
    END
    TypeText                    PREFERRED BRANCH            ALBERT STREET
    ClickElement                //input[@name\='PREFERRED BRANCH']
    ClickText                   ALBERT STREET
    ClickItem                   continue                    tag=button

    # Notifications
    VerifyText                  Notifications
    VerifyText                  Select your preferences below
    ClickElement                //input[@data-value\='true'][@data-name\='depositInfo']
    ClickElement                //input[@data-value\='SMS'][@data-name\='NotifiedMean']
    VerifyText                  SMS notifications will be charged at R 0.50 per SMS
    VerifyText                  We'll send the notifications to your personal cellphone number or email.
    ClickText                   continue                    anchor=back

    # Crosssells
    VerifyText                  Available bundles
    VerifyText                  Business MarketLink
    ClickElement                //input[@data-text\='Business MarketLink | add to bundle click']
    VerifyText                  PocketBiz
    ClickElement                //input[@data-text\='PocketBiz | add to bundle click']
    VerifyText                  SnapScan
    ClickElement                //input[@data-text\='SnapScan | add to bundle click']
    ClickText                   continue                    anchor=back


    VerifyText                  PocketBiz Application
    ClickItem                   listbox                     tag=button
    ClickText                   04                          anchor=MYMOBIZ PLUS APPLICATION
    TypeText                    e.g. coffee shop            Hellium ballons
    TypeText                    merchantCategory            A1 RENT-A-CAR
    ClickElement                //input[@name\='merchantCategory']
    ClickText                   A1 RENT-A-CAR
    ClickText                   continue                    anchor=back


    VerifyText                  SnapScan application
    TypeText                    e.g. coffee shop            hellium ballons
    TypeText                    MERCHANT CATEGORY           A1 RENT-A-CAR
    ClickElement                //input[@name\='MERCHANT CATEGORY']
    ClickText                   A1 RENT-A-CAR
    ClickCheckbox               Receive payments in-store                               on
    ClickCheckbox               Receive payments online     on
    ClickText                   continue                    anchor=back

    # Summary
    VerifyText                  Summary
    LogScreenshot
    VerifyText                  View the items you've added to your bundle
    VerifyText                  MyMoBiz Plus Account
    VerifyText                  Business Marketlink
    VerifyText                  PocketBiz
    VerifyText                  Snap Scan
    LogScreenshot
    ClickText                   confirm                     anchor=back
    ${retry}                    IsText                      RETRY                       timeout=90s
    Log To Console              ${retry}
    IF                          ${retry}
        ClickText               RETRY
    END

    # Sign Legal Agreements
    VerifyText                  Sign Legal Agreements       timeout=90s
    VerifyText                  Application information, disclosures and T&Cs
    VerifyText                  Business transactional account T&Cs
    VerifyText                  Business MarketLink T&Cs
    VerifyText                  PocketBiz application and T&Cs
    VerifyText                  SnapScan application and T&Cs
    VerifyText                  Shareholder Certificate
    # ClickText                 Application information, disclosures and T&Cs
    # Sleep                     7s
    # SwitchWindow              NEW
    # QVision.VerifyText        Identity number ${idnumber}
    # QVision.VerifyText        Cell phone number ${phonenumber}
    # LogScreenshot
    # CloseWindow
    # ClickText                 Business transactional account T&Cs
    # Sleep                     7s
    # SwitchWindow              NEW
    # QVision.VerifyText        Terms and Conditions (Terms) for
    # QVision.VerifyText        Business Transactional Accounts
    # LogScreenshot
    # CloseWindow
    ClickElement                //button[text()\='SIGN']
    VerifyText                  Enter One-time PIN (OTP)    timeout=40s

