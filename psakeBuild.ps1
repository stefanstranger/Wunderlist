properties {
    $script = "$PSScriptRoot\Wunderlist.psm1"
    $pesterscriptroot  = "$PSScriptRoot\.\Tests"
}

task default -depends Analyze, Test

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity @('Error', 'Warning') -ExcludeRule ('PSAvoidUsingConvertToSecureStringWithPlainText','PSUseSingularNouns','PSAvoidGlobalVars','PSUseApprovedVerbs', 'PSUseShouldProcessForStateChangingFunctions' ) -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

task Test {
    $testResults = Invoke-Pester -Path $pesterscriptroot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}


task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path ".\Wunderlist.psdeploy.ps1" -Force -Verbose:$VerbosePreference

    #Update version.txt file
    Set-Content -Path $ModuleVersionPath -Value $NewModuleVersion -Force

}


