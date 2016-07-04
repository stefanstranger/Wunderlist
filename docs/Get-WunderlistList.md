---
external help file: Wunderlist-help.xml
online version: https://developer.wunderlist.com/documentation/endpoints/list
schema: 2.0.0
---

# Get-WunderlistList
## SYNOPSIS
This Function retrieves all Lists a user has permission to.

## SYNTAX

```
Get-WunderlistList
```

## DESCRIPTION
This Function retrieves all Lists a user has permission to.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$DebugPreference = 'continue'; #Enable debug messages to be sent to console
```

$AuthUrl = 'https://www.wunderlist.com/oauth/authorize'; # The base authorization URL from the service provider
$ClientId = 'xxxxxxxxxxxxxxxxxxxx'; # Your registered application's client ID
$RedirectUri = 'http://www.stranger.nl'; # The callback URL configured on your application

#Call Get-oAuth2AccessToken
Get-oAuth2AccessToken \`
 -AuthUrl $AuthUrl \`
 -ClientId $ClientId \`
 -RedirectUri $RedirectUri

Get-WunderlistList -AccessToken '619c400c87156477cce37b4369f1adf8b278437a027bdd83962ba44abeb5' \`
     -ClientId '123456789'

## PARAMETERS

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

[https://developer.wunderlist.com/documentation/endpoints/list](https://developer.wunderlist.com/documentation/endpoints/list)

