function Get-DRSVMRules
    {
    Param([string[]] $Cluster)
    $Old_Rules = Get-DrsRule -Cluster $Cluster -Name "*"
    if ($Old_Rules)
        {
        Remove-DrsRule $Old_Rules -Confirm:$false
        }
    }