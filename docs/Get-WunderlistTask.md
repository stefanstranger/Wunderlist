---
external help file: Wunderlist-help.xml
schema: 2.0.0
online version: https://developer.wunderlist.com/documentation/endpoints/task
---

# Get-WunderlistTask
## SYNOPSIS
This Function retrieves Wunderlist Tasks.
## SYNTAX

```
Get-WunderlistTask [[-Id] <String>] [-Completed] [[-Title] <String>] [<CommonParameters>]
```

## DESCRIPTION
This Function retrieves Wunderlist Tasks within the available Wunderlist Lists.
## EXAMPLES

### Example 1
```
PS C:\> Get-WunderlistTask
```

Get all Wunderlist Tasks for all Lists.

### Example 2
```
PS C:\> Get-WunderlistTask -id 164936522
```

Get all Wunderlist Tasks from a specific Wunderlist List (id).

### Example 3
```
PS C:\>  Get-WunderlistTask -Title "*email
```

Get-WunderlistTask where Title property contains "email".

### Example 4
```
PS C:\>  Get-WunderlistTask -Title "*email*" -completed
```

Get-WunderlistTask where Title property contains "email" and is completed.


## PARAMETERS

### -Completed
Get all Wunderlist Tasks for all Lists which are completed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Wunderlist List Id

```yaml
Type: String
Parameter Sets: (All)
Aliases: ListId

Required: False
Position: 0
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Title
Wunderlist Task Title

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).
## INPUTS

### System.String

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
