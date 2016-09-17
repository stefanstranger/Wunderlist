---
external help file: Wunderlist-help.xml
online version: 
schema: 2.0.0
---

# Remove-WunderlistTask

## SYNOPSIS
This Function removes a Wunderlist Task for a specified List.

## SYNTAX

```
Remove-WunderlistTask [-Id] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This Function removes a Wunderlist Task for a specified List.

## EXAMPLES

### Example 1
```
PS C:\> Remove-WunderlistTask -id 123456
```

Remove Wunderlist Task with id 123456

### Example 2
```
PS C:\> Remove-WunderlistTask -id 123456 -whatif
```

Remove Wunderlist Task with id 123456 and revision number 1 with whatif switch

### Example 3
```
PS C:\> Get-WunderlistList | Get-WunderlistTask | Where-Object {$_.completed -eq $true} | Remove-WunderlistTask -Confirm
```

Confirm the deletion of each Wunderlist Task which is completed

## PARAMETERS

### -Confirm
{{Fill Confirm Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
{{Fill Id Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: TaskId

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf
{{Fill WhatIf Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
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

