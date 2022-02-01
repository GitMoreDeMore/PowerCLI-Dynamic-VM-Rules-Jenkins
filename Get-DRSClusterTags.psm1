function Get-DRSClusterTags
    {
    Param([string] $Cluster,[string[]] $Server_Options)
    $Old_Rules = Get-DrsRule -Cluster $Cluster -Name "*"
    if ($Old_Rules)
        {
        Remove-DrsRule $Old_Rules -Confirm:$false
        }
    foreach($Client_Code in Get-Tag -Category "Client_Code")
	    {
        Add-DRSVMRules $Client_Code.Name $Cluster $Server_Options
	    }
    }