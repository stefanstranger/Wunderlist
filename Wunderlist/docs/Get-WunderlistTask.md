---
external help file: Wunderlist-help.xml
online version: 
schema: 2.0.0
---

# Get-WunderlistTask

## SYNOPSIS
Get Tasks for a List

## SYNTAX

```
Get-WunderlistTask [[-Id] <Int32>] [-Completed] [[-Title] <String>]
```

## DESCRIPTION
Get Tasks for a List

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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Wunderlist List Id

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: ListId

Required: False
Position: 0
Default value: None
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
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.Int32


## OUTPUTS

### System.Management.Automation.PSCustomObject


## NOTES

## RELATED LINKS

