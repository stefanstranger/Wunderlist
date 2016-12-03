Import-Module "$env:home\Documents\GitHub\Wunderlist\Wunderlist" -verbose
New-MarkdownHelp -Module Wunderlist -OutputFolder "$env:home\Documents\GitHub\Wunderlist\Wunderlist\docs"

# re-import your module with latest changes
Import-Module "$env:home\Documents\GitHub\Wunderlist\Wunderlist" -verbose -Force
Update-MarkdownHelp "$env:home\Documents\GitHub\Wunderlist\Wunderlist\docs" -Verbose

#Update for single new Command
New-MarkdownHelp -Command 'Get-WunderlistFolder' -OutputFolder "$env:home\Documents\GitHub\Wunderlist\Wunderlist\docs"


New-ExternalHelp "$env:home\Documents\GitHub\Wunderlist\Wunderlist\docs" -OutputPath "$env:home\\Documents\GitHub\Wunderlist\Wunderlist\en-US" -Force

#Test
remove-module Wunderlist -force
ipmo "$env:home\Documents\GitHub\Wunderlist\wunderlist" -Verbose