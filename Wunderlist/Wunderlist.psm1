<#	
	===========================================================================
	 Created on:   	6/19/2016 12:00 PM
	 Created by:   	Stefan Stranger
	 Filename:     	Wunderlist.psm1
	-------------------------------------------------------------------------
	 Module Name: Wunderlist
	 Description: This Wunderlist PowerShell module was built to give a Wunderlist 
        user the ability to interact with Wunderlist via Powershell.

		Before importing this module, you must create your own Wunderlist application
		on https://developer.wunderlist.com and create an app.
	===========================================================================
#>

#Store Wunderlist ClientID and AccessToken securely
Function Set-WunderlistAuthentication {
[CmdletBinding()]
    Param
    (
        # Wunderlist Client ID.
        [Parameter(Mandatory=$true)]
        [string]$ClientID,
        [Parameter(Mandatory=$true)]
        [string]$AccessToken,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [securestring]$MasterPassword
    )

    Begin
    {
    }
    Process
    {
        $Global:ClientID = $APIKeyClientID
        $Global:AccessToken = $AccessToken
        $SecureClientIDString = ConvertTo-SecureString -String $ClientID -AsPlainText -Force
        $SecureAccessTokenString = ConvertTo-SecureString -String $AccessToken -AsPlainText -Force

        # Generate a random secure Salt
        $SaltBytes = New-Object byte[] 32
        $RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
        $RNG.GetBytes($SaltBytes)

        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword

        # Derive Key, IV and Salt from Key
        $Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)

        $EncryptedClientIDString = $SecureClientIDString | ConvertFrom-SecureString -key $KeyBytes
        $EncryptedAccessTokenString = $SecureAccessTokenString | ConvertFrom-SecureString -key $KeyBytes


        $FolderName = 'Wunderlist'
        $ClientIDConfigName = 'ClientID.key'
        $AccessTokenConfigName = 'AccessToken.key'
        $saltname   = 'salt.rnd'

        (Test-Path -Path "$($env:AppData)\$FolderName")
        if (!(Test-Path -Path "$($env:AppData)\$FolderName"))
        {
            Write-Verbose -Message 'Seems this is the first time the config has been set.'
            Write-Verbose -Message "Creating folder $("$($env:AppData)\$FolderName")"
            New-Item -ItemType directory -Path "$($env:AppData)\$FolderName" | Out-Null
        }
        
        Write-Verbose -Message "Saving the ClientID information to configuration file $("$($env:AppData)\$FolderName\$ClientIDConfigName")"
        "$($EncryptedClientIDString)"  | Set-Content  "$($env:AppData)\$FolderName\$ClientIDConfigName" -Force

        Write-Verbose -Message "Saving the AccessToken information to configuration file $("$($env:AppData)\$FolderName\$AccessTokenConfigName")"
        "$($EncryptedAccessTokenString)"  | Set-Content  "$($env:AppData)\$FolderName\$AccessTokenConfigName" -Force

        # Saving salt in to the file.
        Set-Content -Value $SaltBytes -Encoding Byte -Path "$($env:AppData)\$FolderName\$saltname" -Force
    }
    End
    {
    }

}

function Get-WunderlistData {
    param (
        $RequestUrl
    )

    $headers = Build-AccessHeader
    $result = Invoke-RestMethod -URI $RequestUrl -Method GET -Headers $headers -ContentType 'application/json'
    return $result
}

Function Get-WunderlistUser {
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwu')]
    param()

    process {
        Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/user'
    }
}

Function Get-WunderlistList {
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwl')]
    param (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)][int] [Alias('ListId')] $Id
    )

    process {
    if (!($Id)) 
        {
            Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/lists'
        }
    elseif ($Id)
        {
            $HttpRequestUrl = 'https://a.wunderlist.com/api/v1/lists/{0}' -f $Id
            Get-WunderlistData -RequestUrl $HttpRequestUrl
        }
    }
}

Function Get-WunderlistReminder {
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param (	)

    process {
        Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/reminders'
    }
}

Function Get-WunderlistTask {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwt')]
    param (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)][int] [Alias('ListId')] $Id,
        [Parameter(Mandatory = $false)] [switch] $Completed,
        [Parameter(Mandatory = $false)] [string] $Title="*"
    )

    process {
        
        if (!($Id)) 
        {
            $Lists = Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/lists' 
            if (!($Completed)) 
            {
                $requesturls = foreach ($list in $Lists) 
                {
                    Build-TaskUrl -Id $($list.id)
                }
        
                foreach ($requesturl in $requesturls) 
                {
                    Get-WunderlistData -RequestUrl $requesturl | where-object {$_.title -like $title}
                }
            }
            else 
            {
                $requesturls = foreach ($list in $Lists) 
                {
                    Build-TaskUrl -Id $($list.id) -Completed
                }
        
                foreach ($requesturl in $requesturls) 
                {
                    Get-WunderlistData -RequestUrl $requesturl | where-object {$_.title -like $title}
                }
            }
        }

        else 
        {
            if (!($Completed)) 
            {
                $requesturl = Build-TaskUrl -Id $Id
                Get-WunderlistData -RequestUrl $requesturl | where-object {$_.title -like $title}
            }
            else 
            {
                $requesturl = Build-TaskUrl -Id $Id -Completed
                Get-WunderlistData -RequestUrl $requesturl | where-object {$_.title -like $title}
            }
        }


    }
}

Function New-WunderlistTask {
    [CmdletBinding()]
    [Alias('nwt')]
    param
    (
        [Parameter(Mandatory = $true)]   [int]$listid,        
        [Parameter(Mandatory = $true)]   [string]$title,
        [Parameter(Mandatory = $false)]  [int]$assignee_id,
        [Parameter(Mandatory = $false, ParameterSetName='Recurrence')]  
                                         [bool]$completed,
        [ValidateSet("day", "week", "month","year")]
        [Parameter(Mandatory = $false, ParameterSetName='Recurrence')]
                                         [string]$recurrence_type,
        [Parameter(Mandatory = $false)]  [int]$recurrence_count,
        [Parameter(Mandatory = $false)] 
        [ValidatePattern("^(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])")]      
                                         [string]$due_date,
        [Parameter(Mandatory = $false)]  [bool]$starred

    )
    
    
        $HttpRequesturl =  'https://a.wunderlist.com/api/v1/tasks'

        $hashtable = [ordered]@{'list_id'   = $listid;
                       'title'              = $title;
                       'assignee_id'        = $assignee_id;
                       'completed'          = $completed;
                       'recurrence_type'    = $recurrence_type;
                       'recurrence_count'   = $recurrence_count;
                       'due_date'           = $due_date;
                       'starred'            = $starred;
                      }
        $body = ConvertTo-Json -InputObject $hashtable
        Write-Debug $body
        Write-Verbose 'Creating Request Header'
        $headers = Build-AccessHeader
        write-debug "$($headers.values)"
        $result = Invoke-RestMethod -URI $HttpRequestUrl -Method POST -body $body -Headers $headers -ContentType 'application/json'
        return $result
    
    
}

Function Remove-WunderlistTask {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('rwt')]
    param
    (
        [Parameter(Mandatory  =$true,ValueFromPipelineByPropertyName=$true)]   [string] [Alias("TaskId")] $Id
    )

    process {

        $Wunderlisttask = get-wunderlistList | get-wunderlisttask | Where-Object {$_.id -eq $id} 

        If ($pscmdlet.ShouldProcess($Wunderlisttask.title, "Deleting WunderlistTask"))
        {
            $revision = $Wunderlisttask.revision

            $HttpRequestUrl = 'https://a.wunderlist.com/api/v1/tasks/{0}?revision={1}' -f $id, $revision 
               
            $headers = Build-AccessHeader       
        
            $result = Invoke-RestMethod -URI $HttpRequestUrl -Method DELETE -headers $headers
            $result 
        }
        
    }
}

Function Get-WunderlistNote {
  [CmdletBinding()]
  [OutputType('System.Management.Automation.PSCustomObject')]
  [Alias('gwn')]
  param (
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)][double] $Id,
    [Parameter(ParameterSetName = 'List')][Switch]$List,
    [Parameter(ParameterSetName = 'Task')][Switch]$Task
  )
 
  process {
    if ($List) 
    {
      Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/notes?list_id=$Id"
    }
    elseif (($Task)) 
    {
      Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/notes?task_id=$Id"
    }
  }
}

Function Get-WunderlistFolder {
       [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwf')]
    param (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)][double] $Id
    )

    process {

            #Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/folders?id=$Id"
            if (($id)) 
                 {
                    Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/folders?id=$Id"
                 }
            
            else 
            {
                $folders = Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/folders"
                #Verify list_id in Lists overview
                $folderlistids = $folders.list_ids
                $alllists = (get-wunderlistlist).id
                $existinglist = Compare-Object $folderlistids $alllists -IncludeEqual -ExcludeDifferent | ForEach-Object { $_.InputObject }
                #Retrieve list from folder list_id property
                #$i = 0
                foreach ($folder in $folders)
                {
                    foreach ($list in $existinglist) {
                        #write-verbose $list
                        gwl -id $list  | gwt | select *, @{L='FolderPath';E={$folder.title + '\' + (gwl -id $list).title}} 
                    }
                }

            }
    }
}

#region Helper Functions

function Read-WunderlistAuthentication {
    [CmdletBinding()]

    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [securestring]$MasterPassword
    )

    Begin
    {
        # Test if ClientID file exists.
        if (!(Test-Path "$($env:AppData)\Wunderlist\ClientID.key"))
        {
            throw 'Configuration has not been set, Set-WunderlistAuthentication to configure the API Keys.'
        }
        elseif (!(Test-Path "$($env:AppData)\Wunderlist\AccessToken.key"))
        {
            throw 'Configuration has not been set, Set-WunderlistAuthentication to configure the API Keys.'
        }
    }
    Process
    {
        Write-Verbose -Message "Reading ClientID key from $($env:AppData)\Wunderlist\ClientID.key."
        $ClientIDConfigFileContent = Get-Content -Path "$($env:AppData)\Wunderlist\ClientID.key"
        Write-Debug -Message "ClientID Secure string is $($ClientIDConfigFileContent)"
        
        Write-Verbose -Message "Reading AccessToken key from $($env:AppData)\Wunderlist\AccessToken.key."
        $AccessTokenConfigFileContent = Get-Content -Path "$($env:AppData)\Wunderlist\AccessToken.key"
        Write-Debug -Message "AccessToken Secure string is $($AccessTokenConfigFileContent)"

        $SaltBytes = Get-Content -Encoding Byte -Path "$($env:AppData)\Wunderlist\salt.rnd" 
        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword

        # Derive Key, IV and Salt from Key
        $Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)

        $ClientIDSecString = ConvertTo-SecureString -Key $KeyBytes $ClientIDConfigFileContent
        $AccessTokenSecString = ConvertTo-SecureString -Key $KeyBytes $AccessTokenConfigFileContent

        # Decrypt the secure ClientID string.
        $ClientIDSecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientIDSecString)
        $ClientIDKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($ClientIDSecureStringToBSTR)

        # Decrypt the secure AccessToken string.
        $AccessTokenSecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccessTokenSecString)
        $AccessTokenKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($AccessTokenSecureStringToBSTR)

        # Set session variable with the key.
        Write-Verbose -Message "Setting ClientID key $($ClientIDKey) to variable for use by other commands."
        $Global:ClientID = $ClientIDKey
        Write-Verbose -Message 'ClientID Key has been set.'

        Write-Verbose -Message "Setting AccessToken key $($AccessTokenKey) to variable for use by other commands."
        $Global:AccessToken = $AccessTokenKey
        Write-Verbose -Message 'AccessToken Key has been set.'
    }
    End
    {
    }
}

function Build-AccessHeader {
    [CmdletBinding()]
    param()
    Write-Verbose 'Build-AccessHeader being called'
    #Check if ClientID and\or AccessToken are not available in session
    
    Write-Verbose "Checking for ClientID $env:ClientID and AccessToken $env:AccessToken variables"

    #For AppVeyor Tests also check environment variables
    Write-Verbose "AppVeyor" 
    if (($env:ClientID -and $env:AccessToken)) {
        $Global:AccessToken = $env:AccessToken
        $Global:ClientID = $env:ClientID
    }
    elseif (!($global:ClientID -and $Global:AccessToken)) {
        #Call Read-WunderlistAuthentication Function
        Write-Verbose 'Calling Read-WunderlistAuthentication function'
        Read-WunderlistAuthentication
    }
        

    @{ 
        'X-Access-Token' = $Global:AccessToken
        'X-Client-ID' =  $Global:ClientID
     }
}

function Build-TaskUrl {
    param (
        $Id, 
        [switch]$Completed
    )
    $buildurl = 'Build-TaskUrl: https://a.wunderlist.com/api/v1/tasks?list_id={0}&completed={1}' -f $Id, $Completed.ToString().ToLower()
    write-verbose $buildurl
    'https://a.wunderlist.com/api/v1/tasks?list_id={0}&completed={1}' -f $Id, $Completed.ToString().ToLower()
}

#region Handle Module Removal from idea Boe Prox's PoshRSJob module
$ExecutionContext.SessionState.Module.OnRemove ={

    Remove-Variable AccessToken -Scope Global -Force -ErrorAction SilentlyContinue
    Remove-Variable ClientID -Scope Global -Force -ErrorAction SilentlyContinue

}
#endregion Handle Module Removal

#endregion