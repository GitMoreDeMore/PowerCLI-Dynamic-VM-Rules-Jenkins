function Add-DRSVMRules
    {
    Param([string] $Client_Code,[string] $Cluster,[string[]] $Server_Options)
    foreach($Server_Type in $Server_Options)
        {
        $Match_VMs = Get-VM -Tag $Client_Code | Where-Object {$_.Tag -like "$Server_Type"}
        if ($Match_VMs.count -gt 1)
            {
            Write-Host "$Cluster"
            Write-Host "$Client_Code"
            Write-Host "$Match_VMs"
            New-DrsRule -Cluster $Cluster -Name AA_$Client_Code"_"$Server_Type -KeepTogether $false -VM $Match_VMs
            }
        }
    }