## Create DRS rules dynamically for matching Client_Code/Role Tags

# Add Jenkins Variables
Param($vCenter, $VCUser, $VCPass, $SMTPUser, $SMTPPass, $Confirmation)

## Import PowerCLI Module if not already installed
if ($null -eq (Get-Module -Name VMware.VimAutomation.Cis.Core)) {
	Install-Module VMware.PowerCLI -Scope CurrentUser -Verbose:$false *> $null
}

# Disable CEIP and ignore certificate warnings
Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# Import Function Modules
. .\Modules\Get-AnsiWriteHost.ps1
. .\Modules\Remove-DRSVMRules.ps1
. .\Modules\Get-ClientCodes.ps1
. .\Modules\New-DRSVMRules.ps1

##Global Variables for SMTP
$global:EmailTo = "$SMTPUser"
$global:EmailFrom = "$SMTPUser"
$global:SMTPS = "smtp-mail.outlook.com"
$global:SMTP_Port = 587
$global:SMTPCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $SMTPUser, $($SMTPPass | ConvertTo-SecureString -AsPlainText -Force) 

# Connect to vCenter Server
Connect-VIServer -Server $vCenter -User $VCUser -Password $VCPass -WarningAction SilentlyContinue

# Set affinity Client_Code to keep VMs together
$Affinity_Client_Code = "MD"
# Set exclusions for Role
$Exclude_Role = Get-Tag -Category "Exclude_Role"
$Exclude_Role = $Exclude_Role.name -join '|'

# Gather Workload Tags from vCenter IE. RGI,WEB,MDB
$Role_Options = Get-Tag -Category "Role" | Where-Object { $_.name -notmatch "$Exclude_Role" }

# Loop vCenter Clusters creating rules for matching Client / Workload
foreach ($Cluster in Get-Cluster) {
	Remove-DRSVMRules $Cluster.Name $Confirmation
	Get-ClientCodes $Cluster.Name $Role_Options.Name $Affinity_Client_Code $Confirmation
}

# Disconnect vCenter Server
Disconnect-VIServer -Confirm:$false
