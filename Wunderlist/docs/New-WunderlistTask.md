---
external help file: Wunderlist-help.xml
online version: https://developer.wunderlist.com/documentation/endpoints/task
schema: 2.0.0
---

# New-WunderlistTask

## SYNOPSIS
This Function Creates  new Wunderlist Task for a specified List.

## SYNTAX

```
New-WunderlistTask -listid <Int32> -title <String> [-assignee_id <Int32>] [-completed <Boolean>]
 [-recurrence_type <String>] [-recurrence_count <Int32>] [-due_date <String>] [-starred <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
This Function Creates  new Wunderlist Task for a specified List.

## EXAMPLES

### Example 1
```
PS C:\> New-WunderlistTask -listid '122588396' -title 'Testing Wunderlist from PowerShell'
```

Created new Wunderlist Task for listid '122588396' with the following title 'Testing Wunderlist from PowerShell'

### Example 2
```
PS C:\> $params = @{
               'listid'  = '122588396';
               'title'  = 'Testing posh module';
               'assignee_id'= '10404478';
               'completed' = $true;
               'recurrence_type'= 'day';
               'recurrence_count'= '2';
               'due_date'= '2016-07-30';
               'starred'= $false;
              }

 New-WunderlistTask @params
```

Created new Wunderlist Task for listid '122588396' with the following title 'Testing posh module' assigned to user
with id '10404478' where task is completed and is repeated every two days and is due on date '2016-07-30'

## PARAMETERS

### -assignee_id
Id for assignee of Wunderlist Task

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -completed
Completed status of Wunderlist Task

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -due_date
Date when Wunderlist Task is due

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -listid
Id for the Wunderlist List where to create the Wunderlist Task

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -recurrence_count
Integer on how often the recurrence type is recurrent

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -recurrence_type
Valid options: "day", "week", "month", "year", must be accompanied by recurrence_count

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: day, week, month, year

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -starred
Star for created Wunderlist Task

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -title
Title of Wunderlist Task

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
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

