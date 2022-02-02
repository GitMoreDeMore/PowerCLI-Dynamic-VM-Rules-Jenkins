## Create DRS rules dynamically for matching Client_Code/Workload_Type Tags

# Import Function Modules
. .\Modules\Get-DRSVMRules.ps1
. .\Modules\Get-ClientCodes.ps1
. .\Modules\Add-DRSVMRules.ps1

$vCenter = ""
$User = ""
$Password = ""

# Connect to vCenter Server
Connect-VIServer -Server $vCenter -User $User -Password $Password -WarningAction SilentlyContinue

# Gather Workload Tags from vCenter IE. RGI,WEB,MDB
$Server_Options = Get-Tag -Category "Workload_Type" | Where-Object {$_.name -notmatch "MOD|TRASH|GARBAGE"}

# Loop vCenter Clusters creating rules for matching Client / Workload
foreach($Cluster in Get-Cluster)
	{
    Get-DRSVMRules $Cluster.Name
	Get-ClientCodes $Cluster.Name $Server_Options.Name
	}

# Disconnect vCenter Server
Disconnect-VIServer -confirm:$false