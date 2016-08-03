#Variables for Pester tests

$ModulePath= split-path -parent(Split-Path -Parent $MyInvocation.MyCommand.Path)
$ModuleName = 'Wunderlist'
$ManifestPath   = "$ModulePath\$ModuleName.psd1"
if (Get-Module -Name $ModuleName) { Remove-Module $ModuleName -Force }
Import-Module $ManifestPath -Verbose:$false

$Global:ModuleVersionPath = "$($PSScriptRoot)\version.txt"

#Check for version file in Tests folder
Write-Verbose "Checking for Version.txt file"
if (!(Test-path $ModuleVersionPath))
{
    Set-Content -Path $ModuleVersionPath -Value "1.0.0"
}


# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe "Manifest" {
    
    $ManifestHash = Invoke-Expression (Get-Content $ManifestPath -Raw)

    It "has a valid manifest" {
        {
            $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid root module" {
        $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
    }

    It "has a valid Description" {
        $ManifestHash.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        $ManifestHash.Guid | Should Be '8418f0c1-db0c-4605-85b6-4ed52b460160'
    }

    It "has a valid version" {
        $ManifestHash.ModuleVersion -as [Version] | Should Not BeNullOrEmpty
    }

    It "has a valid copyright" {
        $ManifestHash.CopyRight | Should Not BeNullOrEmpty
    }

    It 'has a valid license Uri' {
        $ManifestHash.PrivateData.Values.LicenseUri | Should Be 'http://opensource.org/licenses/MIT'
    }
    
    It 'has a valid project Uri' {
        $ManifestHash.PrivateData.Values.ProjectUri | Should Be 'https://github.com/stefanstranger/Wunderlist'
    }
    
    It "gallery tags don't contain spaces" {
        foreach ($Tag in $ManifestHash.PrivateData.Values.tags)
        {
            $Tag -notmatch '\s' | Should Be $true
        }
    }

    It 'Module version should be higher then last published version' {
        $LatestModuleVersion = get-content $ModuleVersionPath
        $Global:NewModuleVersion = $ManifestHash.ModuleVersion
        $ManifestHash.ModuleVersion | Should BeGreaterThan $LatestModuleVersion 
        
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


        <#
        It 'Passes Set-WunderlistAuthentication Function ' {
            
            Mock Set-Content {}

            Set-WunderlistAuthentication | Should Not Be $null

        }
        #>


    }

}
