Import-Module 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist' -verbose
New-MarkdownHelp -Module Wunderlist -OutputFolder 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist\docs'

# re-import your module with latest changes
Import-Module 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist' -verbose -Force
Update-MarkdownHelp 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist\docs' -Verbose


New-ExternalHelp 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist\docs' -OutputPath 'C:\Users\Stefan\Documents\GitHub\Wunderlist\Wunderlist\en-US\' -Force

#Test
remove-module Wunderlist -force
ipmo C:\users\Stefan\Documents\GitHub\Wunderlist\wunderlist -Verbose