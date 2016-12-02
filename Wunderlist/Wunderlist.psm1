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
Function Set-WunderlistAuthentication 
{
    [CmdletBinding()]
    Param
    (
        # Wunderlist Client ID.
        [Parameter(Mandatory = $true)]
        [string]$ClientID,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
        Position = 1)]
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
        $SaltBytes = New-Object -TypeName byte[] -ArgumentList 32
        $RNG = New-Object -TypeName System.Security.Cryptography.RNGCryptoServiceProvider
        $RNG.GetBytes($SaltBytes)

        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword

        # Derive Key, IV and Salt from Key
        $Rfc2898Deriver = New-Object -TypeName System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)

        $EncryptedClientIDString = $SecureClientIDString | ConvertFrom-SecureString -Key $KeyBytes
        $EncryptedAccessTokenString = $SecureAccessTokenString | ConvertFrom-SecureString -Key $KeyBytes


        $FolderName = 'Wunderlist'
        $ClientIDConfigName = 'ClientID.key'
        $AccessTokenConfigName = 'AccessToken.key'
        $saltname   = 'salt.rnd'

        (Test-Path -Path "$($env:AppData)\$FolderName")
        if (!(Test-Path -Path "$($env:AppData)\$FolderName"))
        {
            Write-Verbose -Message 'Seems this is the first time the config has been set.'
            Write-Verbose -Message "Creating folder $("$($env:AppData)\$FolderName")"
            $null = New-Item -ItemType directory -Path "$($env:AppData)\$FolderName"
        }
        
        Write-Verbose -Message "Saving the ClientID information to configuration file $("$($env:AppData)\$FolderName\$ClientIDConfigName")"
        "$($EncryptedClientIDString)"  | Set-Content  -Path "$($env:AppData)\$FolderName\$ClientIDConfigName" -Force

        Write-Verbose -Message "Saving the AccessToken information to configuration file $("$($env:AppData)\$FolderName\$AccessTokenConfigName")"
        "$($EncryptedAccessTokenString)"  | Set-Content  -Path "$($env:AppData)\$FolderName\$AccessTokenConfigName" -Force

        # Saving salt in to the file.
        Set-Content -Value $SaltBytes -Encoding Byte -Path "$($env:AppData)\$FolderName\$saltname" -Force
    }
    End
    {
    }
}

function Get-WunderlistData 
{
    Param 
    (
        $RequestUrl
    )

    $headers = Build-AccessHeader
    $result = Invoke-RestMethod -Uri $RequestUrl -Method GET -Headers $headers -ContentType 'application/json'
    return $result
}

Function Get-WunderlistUser 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwu')]
    Param
    (
    )
	
    Process {
        Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/user'
    }
}

Function Get-WunderlistFolder 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwf')]
    Param 
    (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)][int64] $Id
    )
 
    Process {
        #Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/folders?id=$Id"
        if (($Id)) 
        {
            Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/folders?id=$Id"
        }
        else 
        {
            $folders = Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/folders'
            if ($folders)
            {
                #Retrieve list from folder list_id property
                $i = 0
                foreach ($folder in $folders)
                {
                    foreach ($list in ($folder.list_ids)) 
                    {
                        $mylist = Get-WunderlistList -Id $list -ErrorAction SilentlyContinue #ugly way to surpress retrieving list_ids that don't exist anymore
                        if ($mylist) 
                        {
                        $mylist | Get-WunderlistTask | 
                            Select-Object -Property *, @{
                                L = 'FolderPath'
                                        E = {
                                $folder.title + '\' + (Get-WunderlistList -Id $list).title
                            }
                            }
                        }
                    }
                }
            }
            else
            {
                Write-Warning 'No Wunderlist list found'
            }
        }
    }
}

Function Get-WunderlistList 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwl')]
    Param 
    (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]	[int] [Alias('ListId')] $Id
    )

    Process {
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

Function Get-WunderlistReminder 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    Param 
    (	
    )

    Process {
        Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/reminders'
    }
}

Function Get-WunderlistTask 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwt')]
    Param 
    (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)][int] [Alias('ListId')] $Id,
        [Parameter(Mandatory = $false)] [switch] $Completed,
        [Parameter(Mandatory = $false)] [string] $Title = '*'
    )

    Process {
        
        if (!($Id)) 
        {
            $Lists = Get-WunderlistData -RequestUrl 'https://a.wunderlist.com/api/v1/lists' 
            if (!($Completed)) 
            {
                $requesturls = foreach ($list in $Lists) 
                {
                    Build-TaskUrl -Id $($list.id)
                }
        
                foreach ($RequestUrl in $requesturls) 
                {
                    Get-WunderlistData -RequestUrl $RequestUrl | Where-Object -FilterScript {
                        $_.title -like $Title
                    }
                }
            }
            else 
            {
                $requesturls = foreach ($list in $Lists) 
                {
                    Build-TaskUrl -Id $($list.id) -Completed
                }
        
                foreach ($RequestUrl in $requesturls) 
                {
                    Get-WunderlistData -RequestUrl $RequestUrl | Where-Object -FilterScript {
                        $_.title -like $Title
                    }
                }
            }
        }
        else 
        {
            if (!($Completed)) 
            {
                $RequestUrl = Build-TaskUrl -Id $Id
                Get-WunderlistData -RequestUrl $RequestUrl | Where-Object -FilterScript {
                    $_.title -like $Title
                }
            }
            else 
            {
                $RequestUrl = Build-TaskUrl -Id $Id -Completed
                Get-WunderlistData -RequestUrl $RequestUrl | Where-Object -FilterScript {
                    $_.title -like $Title
                }
            }
        }
    }
}

Function New-WunderlistTask 
{
    [CmdletBinding()]
    [Alias('nwt')]
    param
    (
        [Parameter(Mandatory = $true)]   [int]$listid,        
        [Parameter(Mandatory = $true)]   [string]$Title,
        [Parameter(Mandatory = $false)]  [int]$assignee_id,
        [Parameter(Mandatory = $false, ParameterSetName = 'Recurrence')]  
        [bool]$Completed,
        [ValidateSet('day', 'week', 'month','year')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Recurrence')]
        [string]$recurrence_type,
        [Parameter(Mandatory = $false)]  [int]$recurrence_count,
        [Parameter(Mandatory = $false)] 
        [ValidatePattern('^(19|20)\d\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])')]      
        [string]$due_date,
        [Parameter(Mandatory = $false)]  [bool]$starred

    )
    
    
    $HttpRequestUrl = 'https://a.wunderlist.com/api/v1/tasks'

    $hashtable = [ordered]@{
        'list_id'        = $listid
        'title'          = $Title
        'assignee_id'    = $assignee_id
        'completed'      = $Completed
        'recurrence_type' = $recurrence_type
        'recurrence_count' = $recurrence_count
        'due_date'       = $due_date
        'starred'        = $starred
    }
    $body = ConvertTo-Json -InputObject $hashtable
    Write-Debug $body
    Write-Verbose 'Creating Request Header'
    $headers = Build-AccessHeader
    Write-Debug "$($headers.values)"
    $result = Invoke-RestMethod -Uri $HttpRequestUrl -Method POST -Body $body -Headers $headers -ContentType 'application/json'

    return $result
}

Function Remove-WunderlistTask 
{
    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'Medium')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('rwt')]
    Param
    (
        [Parameter(Mandatory  = $true,ValueFromPipelineByPropertyName = $true)]   [string] [Alias('TaskId')] $Id
    )

    Process {

        $Wunderlisttask = Get-WunderlistList |
        Get-WunderlistTask |
        Where-Object -FilterScript {
            $_.id -eq $Id
        } 

        If ($pscmdlet.ShouldProcess($Wunderlisttask.title, 'Deleting WunderlistTask'))
        {
            $revision = $Wunderlisttask.revision

            $HttpRequestUrl = 'https://a.wunderlist.com/api/v1/tasks/{0}?revision={1}' -f $Id, $revision 
               
            $headers = Build-AccessHeader       
        
            $result = Invoke-RestMethod -Uri $HttpRequestUrl -Method DELETE -Headers $headers
            $result 
        }
        
    }
}

Function Get-WunderlistNote 
{
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [Alias('gwn')]
    Param 
    (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)][double] $Id,
        [Parameter(ParameterSetName = 'List')][Switch]$list,
        [Parameter(ParameterSetName = 'Task')][Switch]$Task
    )
 
    Process {
        if ($list) 
        {
            Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/notes?list_id=$Id"
        }
        elseif (($Task)) 
        {
            Get-WunderlistData -RequestUrl "https://a.wunderlist.com/api/v1/notes?task_id=$Id"
        }
    }
}

#region Helper Functions

function Read-WunderlistAuthentication 
{
    [CmdletBinding()]

    Param
    (

        [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
        Position = 0)]
        [securestring]$MasterPassword
    )

    Begin
    {
        # Test if ClientID file exists.
        if (!(Test-Path -Path "$($env:AppData)\Wunderlist\ClientID.key"))
        {
            throw 'Configuration has not been set, Set-WunderlistAuthentication to configure the API Keys.'
        }
        elseif (!(Test-Path -Path "$($env:AppData)\Wunderlist\AccessToken.key"))
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
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword

        # Derive Key, IV and Salt from Key
        $Rfc2898Deriver = New-Object -TypeName System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)

        $ClientIDSecString = ConvertTo-SecureString -Key $KeyBytes -String $ClientIDConfigFileContent
        $AccessTokenSecString = ConvertTo-SecureString -Key $KeyBytes -String $AccessTokenConfigFileContent

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

function Build-AccessHeader 
{
    [CmdletBinding()]
    Param
    (
    )
    
    Write-Verbose 'Build-AccessHeader being called'
    #Check if ClientID and\or AccessToken are not available in session
    
    Write-Verbose "Checking for ClientID $env:ClientID and AccessToken $env:AccessToken variables"

    #For AppVeyor Tests also check environment variables
    Write-Verbose 'AppVeyor' 
    if (($env:ClientID -and $env:AccessToken)) 
    {
        $Global:AccessToken = $env:AccessToken
        $Global:ClientID = $env:ClientID
    }
    elseif (!($Global:ClientID -and $Global:AccessToken)) 
    {
        #Call Read-WunderlistAuthentication Function
        Write-Verbose 'Calling Read-WunderlistAuthentication function'
        Read-WunderlistAuthentication
    }
        

    @{
        'X-Access-Token' = $Global:AccessToken
        'X-Client-ID'  = $Global:ClientID
    }
}

function Build-TaskUrl 
{
    Param 
    (
        $Id, 
        [switch]$Completed
    )
    $buildurl = 'Build-TaskUrl: https://a.wunderlist.com/api/v1/tasks?list_id={0}&completed={1}' -f $Id, $Completed.ToString().ToLower()
    Write-Verbose $buildurl
    'https://a.wunderlist.com/api/v1/tasks?list_id={0}&completed={1}' -f $Id, $Completed.ToString().ToLower()
}

#region Handle Module Removal from idea Boe Prox's PoshRSJob module
$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-Variable -Name AccessToken -Scope Global -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name ClientID -Scope Global -Force -ErrorAction SilentlyContinue
}
#endregion Handle Module Removal

#endregion