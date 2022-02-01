##Create DRS rules dynamically for matching Client_Code/Workload_Type

# Import Function Modules
Import-Module -Name .\Modules\Get-DRSClusterTags.psm1
Import-Module -Name .\Modules\Add-DRSVMRules.psm1

# Connect to vCenter Server
Connect-VIServer -Server 192.168.1.159 -User -Password -WarningAction SilentlyContinue

# Gather Workload Tags from vCenter IE. RGI,WEB,MDB
$Server_Options = Get-Tag -Category "Workload_Type" | Where-Object {$_.name -notmatch "TEST|TRASH|GARBAGE"}

# Loop vCenter Clusters creating rules for matching Client / Workload
foreach($Cluster in Get-Cluster)
	{
    Get-DRSClusterTags $Cluster $Server_Options.name
	}

# Disconnect vCenter Server
Disconnect-VIServer -confirm:$false