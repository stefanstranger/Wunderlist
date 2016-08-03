#requires -Version 3

# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
  # Find the build folder based on build system
  $ProjectRoot = $ENV:BHProjectPath
  if(-not $ProjectRoot)
  {
    $ProjectRoot = $PSScriptRoot
  }

  $Timestamp = Get-Date -UFormat '%Y%m%d-%H%M%S'
  $PSVersion = $PSVersionTable.PSVersion.Major
  $TestFile = "TestResults_PS$PSVersion`_$Timestamp.xml"
  $lines = '----------------------------------------------------------------------'

  $Verbose = @{}
  if($ENV:BHCommitMessage -match '!verbose')
  {
    $Verbose = @{
      Verbose = $True
    }
  }

  #psake is a build automation tool written in PowerShell

  Properties {
    $script = "$PSScriptRoot\Wunderlist.psm1"
    $pesterscriptroot  = "$PSScriptRoot\.\Tests"
  }

  Task Default -Depends Deploy

  Task Init {
    $lines
    Set-Location $($ProjectRoot)   
    'Build System Details:'
    $null = New-Item ENV:BHModuleFullName -Value (Get-Item $ENV:BHProjectPath\*.psm1).FullName -Force #Needed for ScriptAnalyzer
    Get-Item ENV:BH*
    
    "`n"
  }

  Task Analyze {
    $lines
    "`n`tSTATUS: Testing with ScriptAnalyzer PowerShell $PSVersion"

    $saResults = Invoke-ScriptAnalyzer -Path $($ENV:BHModuleFullName) -Severity @('Error', 'Warning') -ExcludeRule ('PSAvoidUsingConvertToSecureStringWithPlainText', 'PSUseSingularNouns', 'PSAvoidGlobalVars', 'PSUseApprovedVerbs', 'PSUseShouldProcessForStateChangingFunctions' ) -Recurse -Verbose:$false
    if ($saResults) 
    {
      $saResults | Format-Table  
      Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
    else
    {
      Write-Host 'No errors found by Script Analyzer' -ForegroundColor Green
    }
  }

  Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Testing with Pester PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    "$ProjectRoot\$TestFile"
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
      (New-Object 'System.Net.WebClient').UploadFile(
        "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
      "$ProjectRoot\$TestFile" )
    }


    else
    {
      Write-Host 'No Test errors found by Pester' -ForegroundColor Green
    }
  }


  Remove-Item -Path "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

  # Failed tests?
  # Need to tell psake or it will proceed to the deployment. Danger!
  if($TestResults.FailedCount -gt 0)
  {
    Write-Error -Message "Failed '$($TestResults.FailedCount)' tests, build failed"
  }
  "`n"
}

Task Build -Depends Test {
  $lines
    
  # Load the module, read the exported functions, update the psd1 FunctionsToExport
  Set-ModuleFunctions

  # Bump the module version
  Update-Metadata -Path $env:BHPSModuleManifest
}

Task Deploy -Depends Build {
  $lines

  $Params = @{
    Path    = $ProjectRoot
    Force   = $True
    Recurse = $false
  }
  Invoke-PSDeploy @Verbose @Params
}