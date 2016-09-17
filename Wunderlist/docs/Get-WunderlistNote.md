---
external help file: Wunderlist-help.xml
online version: https://developer.wunderlist.com/documentation/endpoints/note
schema: 2.0.0
---

# Get-WunderlistNote
## SYNOPSIS
This Function retrieves the Notes for a Task or List.

## SYNTAX

### List
```
Get-WunderlistNote -Id <String> [-List]
```

### Task
```
Get-WunderlistNote -Id <String> [-Task]
```

## DESCRIPTION
This Function retrieves the Notes for a Task or List.

## EXAMPLES

### Example 1
```
PS C:\> Get-WunderlistNote -Task -Id 2091297441
```
Get's the Note from the Task with Id 2091297441

### Example 2
```
PS C:\> Get-WunderlistNote -List -Id 126300146
```
Get's the Note from the List with Id 2091297441

### Example 3
```
PS C:\> Get-WunderlistTask | Get-WunderlistNote -Task
```
Get Wunderlist Note(s) for all Tasks

### Example 4
```
PS C:\> Get-WunderlistList | Get-WunderlistNote -List
```
Get-Wunderlist Note for a all Lists

## PARAMETERS

### -Id
Task Id (integer)

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -List
Select this switch parameter for Notes per List

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Task
Select this switch parameter for Notes per Task

```yaml
Type: SwitchParameter
Parameter Sets: Task
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.String


## OUTPUTS

### System.Management.Automation.PSCustomObject


## NOTES

## RELATED LINKS

