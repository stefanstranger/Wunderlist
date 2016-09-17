---
external help file: Wunderlist-help.xml
online version: https://developer.wunderlist.com/documentation/endpoints/list
schema: 2.0.0
---

# Get-WunderlistList

## SYNOPSIS
This Function retrieves all Wunderlist Lists a user has permission to.

## SYNTAX

```
Get-WunderlistList [-Id <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This Function retrieves all Wunderlist Lists a user has permission to.

## EXAMPLES

### Example 1
```
PS C:\> Get-WunderlistList
```

Retrieves all Wunderlist Lists where user has permission to.

### Example 2
```
PS C:\> Get-WunderlistList -id 265967075
```

Retrieves Wunderlist List with id 265967075

## PARAMETERS

### -Id
List Id

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: ListId

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

