*** Settings ***
Library    String
Library    QWeb

*** Keywords ***
RGB To Hex
    [Documentation]    Converts RGB/RGBA color to hexadecimal
    [Arguments]    ${rgb_string}
    # Extract RGB values using regular expression
    ${color_values}=    Evaluate    [int(x) for x in "${rgb_string}".strip("rgba()").split(",")[:3]]
    ${hex_color}=    Evaluate    '\#{:02x}{:02x}{:02x}'.format(*${color_values})
    RETURN    ${hex_color}

Get Header Color In Hex
    [Documentation]    Gets header background color in hex format
    ${elem}=    GetWebElement    //h1    # or appropriate header selector
    ${rgba_color}=    Evaluate    $elem[0].value_of_css_property("background-color")
    ${hex_color}=    RGB To Hex    ${rgba_color}
    RETURN    ${hex_color}

*** Test Cases ***
Verify Header Color In Hex
    ${header_hex_color}=    Get Header Color In Hex
    Should Be Equal    ${header_hex_color}    \#014486    # Example hex color
    Log    Header color in hex: ${header_hex_color}