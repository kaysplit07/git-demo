Perf
| where ObjectName == "Memory" 
| where CounterName == "Available MBytes"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| join kind=inner (ResourceContainers
  | where Type == "microsoft.compute/virtualmachines"
  | where Location == "YourRegion"  // Specify your region here
) on $left.Computer == $right.name
| where avg_CounterValue < 500  // Alert if available memory is less than 500MB
| project TimeGenerated, Computer, avg_CounterValue, Location
