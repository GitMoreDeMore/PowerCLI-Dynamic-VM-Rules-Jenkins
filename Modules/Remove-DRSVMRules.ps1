function Remove-DRSVMRules($Cluster, $Confirmation) {
    $Old_Rules = Get-DrsRule -Cluster $Cluster -Name "*"
    if ($Old_Rules) {
        if ($Confirmation -eq 'yes') {
            Remove-DrsRule $Old_Rules -Confirm:$false
        }
        else {
            Write-Host "Old Rules: $Old_Rules" -ForegroundColor DarkRed -BackgroundColor Black
        }
    }
}