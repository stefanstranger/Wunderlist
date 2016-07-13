# Wunderlist
PowerShell Module for Wunderlist

07/13/2016: - Initial version

# Install
1. Download the zip file.
2. Unblock the zip file.
3. Extract contents to PowerShell Module folder of your choice.
4. Run import-module Wunderlist cmdlet in PowerShell after following below steps.

# Wunderlist Register your app
1. Go to https://developer.wunderlist.com/
2. Login with your Wunderlist account.
3. Register your app.
4. Enter a name for your awesome app.
5. Enter a description for your application.
6. Enter the URL for your application.
7. Enter URL to receive the authorization code.
8. On first usage you need to securely store your Wunderlist ClientId and AccessToken.
   - Retrieve your AccessToken on the https://developer.wunderlist.com/apps by clicking on the Create AccessToken button.
   - Run Set-WunderlistAuthentication -ClientID [yourclientid] -AccessToken [youraccesstoken] cmdlet
   You should be asked to enter a password to securely store you ClientID and AccessToken on your system.
10. Now you are ready to start using the Wunderlist module.

