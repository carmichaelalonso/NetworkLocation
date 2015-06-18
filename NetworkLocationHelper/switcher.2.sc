tell application "System Events"
tell network preferences
get the name of current location as text
set a to the result
end tell
end tell
tell application "Finder"
activate
display dialog "You are using network " & a with icon 1
display dialog "Do you want to change networks?" with icon 1 buttons {"Airport #1", "Ethernet #1", "No"} default button 3
set userChoice to button returned of the result
if userChoice is "Airport #1" then
    do shell script "/usr/sbin/networksetup -setairportpower airport on"
    delay 2.5
    do shell script "scselect XXX12345-111X-4E68-AA35-CA6D04D5A2BF"
    else
    if userChoice is "Ethernet #1" then
        do shell script "/usr/sbin/networksetup -setairportpower airport off"
        delay 0.5
        do shell script "scselect 1824XX49-ADE6-496F-A107-B2F7F57903F5"
    end if
end if
end tell