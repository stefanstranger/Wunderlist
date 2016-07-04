$ModuleManifestName = 'Wunderlist.psd1'
# 32061ca2-cb32-469c-991a-d1cab644e576 - testing use of PLASTER predefined variables.
Import-Module $PSScriptRoot\..\$ModuleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $PSScriptRoot\..\$ModuleManifestName
        $? | Should Be $true
    }
}

Describe 'Module Wunderlist works' {
    It 'Passed Module load' {
        Get-Module -name 'Wunderlist' | Should Not Be $null
    }
}


Describe 'Test Functions in Wunderlist Module' {
    Context 'Testing Public Functions' {

        It 'Passes New-WunderlistTaks Function' {
            $result = New-WunderlistTask -listid '126300146' -title 'Wunderlist Pester Test'
            $result.title | Should Be 'Wunderlist Pester Test'

        }

        It 'Passes Get-WunderlistUser Function' {
            Get-WunderlistUser | Should Not Be $null        
        }

        It 'Passes Get-WunderlistTask Function' {
            Get-WunderlistTask | Should Not Be $null
        
        }

        It 'Passes Get-WunderlistList Function' {
            Get-WunderlistList| Should Not Be $null
        
        }

        It 'Passes Get-WunderlistReminder Function' {
            Get-WunderlistReminder | Should Not Be $null
        
        }
        
        <#Fails because Task is not available yet.
        It 'Passes Remove-WunderlistTask Function' {
            $result = Get-WunderlistTask -Title 'Wunderlist Pester Test' | Remove-WunderlistTask
            $result.title | Should Be 'Wunderlist Pester Test'

        }
        #>
    }

    Context 'Testing Private Functions' {
        It 'Passes Build-AccessHeader Function ' {

            Build-AccessHeader | Should Not Be $null

        }

        It 'Passes Read-WunderlistAuthentication Function' {
            #Set MasterPassword. Remove MasterPassword.txt file before publication to PSGallery
            $MasterPassword = Get-Content -Path "$PSScriptRoot\MasterPassword.txt" | ConvertTo-SecureString -AsPlainText -Force
            Read-WunderlistAuthentication -MasterPassword $MasterPassword
            $Global:ClientId | Should Not Be $null
            $Global:AccessToken | Should Not Be $null

        }

        <#
        It 'Passes Set-WunderlistAuthentication Function ' {
            
            Mock Set-Content {}

            Set-WunderlistAuthentication | Should Not Be $null

        }
        #>


    }

}
