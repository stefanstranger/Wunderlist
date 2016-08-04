#requires -Version 3
#Variables for Pester tests

$ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
$ModuleName = 'Wunderlist'
$ManifestPath   = "$ModulePath\Wunderlist\$ModuleName.psd1"
if (Get-Module -Name $ModuleName) 
{
  Remove-Module $ModuleName -Force 
}
Import-Module $ManifestPath -Verbose:$false

$Global:ModuleVersionPath = "$($PSScriptRoot)\version.txt"


# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe -Name 'Manifest' -Fixture {
  $ManifestHash = Invoke-Expression -Command (Get-Content $ManifestPath -Raw)

  It -name 'has a valid manifest' -test {
    {
      $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
    } | Should Not Throw
  }

  It -name 'has a valid root module' -test {
    $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
  }

  It -name 'has a valid Description' -test {
    $ManifestHash.Description | Should Not BeNullOrEmpty
  }

  It -name 'has a valid guid' -test {
    $ManifestHash.Guid | Should Be '8418f0c1-db0c-4605-85b6-4ed52b460160'
  }

  It -name 'has a valid version' -test {
    $ManifestHash.ModuleVersion -as [Version] | Should Not BeNullOrEmpty
  }

  It -name 'has a valid copyright' -test {
    $ManifestHash.CopyRight | Should Not BeNullOrEmpty
  }

  It -name 'has a valid license Uri' -test {
    $ManifestHash.PrivateData.Values.LicenseUri | Should Be 'http://opensource.org/licenses/MIT'
  }
    
  It -name 'has a valid project Uri' -test {
    $ManifestHash.PrivateData.Values.ProjectUri | Should Be 'https://github.com/stefanstranger/Wunderlist'
  }
    
  It -name "gallery tags don't contain spaces" -test {
    foreach ($Tag in $ManifestHash.PrivateData.Values.tags)
    {
      $Tag -notmatch '\s' | Should Be $true
    }
  }

  It -name 'Module version should be higher then last published version' -test {
    $LatestModuleVersion = Get-Content $ModuleVersionPath
    $Global:NewModuleVersion = $ManifestHash.ModuleVersion
    $ManifestHash.ModuleVersion | Should BeGreaterThan $LatestModuleVersion
  }
}


Describe -Name 'Module Wunderlist works' -Fixture {
  It -name 'Passed Module load' -test {
    Get-Module -Name 'Wunderlist' | Should Not Be $null
  }
}


Describe -Name 'Test Functions in Wunderlist Module' -Fixture {
  Context -Name 'Testing Public Functions' -Fixture {
    It -name 'Passes New-WunderlistTaks Function' -test {
      $result = New-WunderlistTask -listid '126300146' -title 'Wunderlist Pester Test'
      $result.title | Should Be 'Wunderlist Pester Test'
    }

    It -name 'Passes Get-WunderlistUser Function' -test {
      Get-WunderlistUser | Should Not Be $null
    }

    It -name 'Passes Get-WunderlistTask Function' -test {
      Get-WunderlistTask | Should Not Be $null
    }

    It -name 'Passes Get-WunderlistList Function' -test {
      Get-WunderlistList| Should Not Be $null
    }

    It -name 'Passes Get-WunderlistReminder Function' -test {
      Get-WunderlistReminder | Should Not Be $null
    }
        
    <#Fails because Task is not available yet.
        It 'Passes Remove-WunderlistTask Function' {
        $result = Get-WunderlistTask -Title 'Wunderlist Pester Test' | Remove-WunderlistTask
        $result.title | Should Be 'Wunderlist Pester Test'

        }
    #>
  }

  Context -Name 'Testing Private Functions' -Fixture {
    It -name 'Passes Build-AccessHeader Function ' -test {
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
