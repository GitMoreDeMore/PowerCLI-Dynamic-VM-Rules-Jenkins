##Create DRS rules dynamically for matching Client_Code/Workload_Type Tags

# Connect to vCenter Server
Connect-VIServer -Server 192.168.1.159 -WarningAction SilentlyContinue

# Import Function Modules
Import-Module -Name .\Modules\Get-DRSVMRules.ps1
Import-Module -Name .\Modules\Get-ClientCodes.ps1
Import-Module -Name .\Modules\Add-DRSVMRules.ps1

# Gather Workload Tags from vCenter IE. RGI,WEB,MDB
$Server_Options = Get-Tag -Category "Workload_Type" | Where-Object {$_.name -notmatch "TRASH|GARBAGE"}

# Loop vCenter Clusters creating rules for matching Client / Workload
foreach($Cluster in Get-Cluster)
	{
    Get-DRSVMRules $Cluster
	Get-ClientCodes $Cluster $Server_Options.Name
	}

# Disconnect vCenter Server
Disconnect-VIServer -confirm:$false