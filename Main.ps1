## Create DRS rules dynamically for matching Client_Code/Role Tags

# Add Jenkins Variables
Param($vCenter,$VCUser,$VCPassword,$SMTPUser,$SMTPPass)

# Import Function Modules
. .\Modules\Remove-DRSVMRules.ps1
. .\Modules\Get-ClientCodes.ps1
. .\Modules\New-DRSVMRules.ps1

##Global Variables for SMTP
$global:EmailTo = "$SMTPUser"
$global:EmailFrom = "$SMTPUser"
$global:SMTPS = "smtp-mail.outlook.com"
$global:SMTP_Port = 587

$Confirmation ="no"

# Connect to vCenter Server
Connect-VIServer -Server $vCenter -User $VCUser -Password $VCPassword -WarningAction SilentlyContinue

# Set affinity Client_Code to keep VMs together
$Affinity_Client_Code = "MD"
# Set exclusions for Role
$Exclude_Role = Get-Tag -Category "Exclude_Role"
$Exclude_Role = $Exclude_Role.name -join '|'

# Gather Workload Tags from vCenter IE. RGI,WEB,MDB
$Role_Options = Get-Tag -Category "Role" | Where-Object {$_.name -notmatch "$Exclude_Role"}

# Loop vCenter Clusters creating rules for matching Client / Workload
#Dry Run
foreach($Cluster in Get-Cluster)
	{
	Remove-DRSVMRules $Cluster.Name $Confirmation
	Get-ClientCodes $Cluster.Name $Role_Options.Name $Affinity_Client_Code $Confirmation
	}

#Actual run
$Confirmation = Read-Host "Do You Want To Proceed"
if ($Confirmation -eq "y" -or $Confirmation -eq "yes")
	{
	foreach($Cluster in Get-Cluster)
		{
		Remove-DRSVMRules $Cluster.Name $Confirmation
		Get-ClientCodes $Cluster.Name $Role_Options.Name $Affinity_Client_Code $Confirmation
		}
	}
else
	{
	Write-Host "Aborting..."
	}

# Disconnect vCenter Server
Disconnect-VIServer -confirm:$false
