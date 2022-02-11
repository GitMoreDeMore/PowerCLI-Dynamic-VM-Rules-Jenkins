function New-DRSVMRules($Client_Code, $Cluster, [string[]]$Role_Options, $Affinity_Client_Code, $Confirmation)
    {
    foreach($Role_Type in $Role_Options)
        {
        $Host_Count = Get-Cluster -Name $Cluster
        $Host_Count = $Host_Count.ExtensionData.Host.Count
        $Match_VMs = Get-VM -Tag $Client_Code | Get-TagAssignment | Where-Object { $_.Tag -like "*$Role_Type*"}
        if ($Match_VMs.count -gt 1 -and $Match_VMs.count -le $Host_Count)
            {
            if ($Client_Code -notlike "$Affinity_Client_Code")
                {
                if ($Confirmation -eq 'yes')
                    {
                    New-DrsRule -Cluster $Cluster -Name AA"_"$Client_Code"_"$Role_Type -KeepTogether $false -VM $Match_VMs.Entity.Name
                    }
                else
                    {
                    Write-Host Anti-Affinity $Client_Code $Role_Type VMs: $Match_VMs.Entity.Name -ForegroundColor DarkGreen
                    }
                }
            else
                {
                if ($Confirmation -eq 'yes')
                    {
                    New-DrsRule -Cluster $Cluster -Name A"_"$Client_Code"_"$Role_Type -KeepTogether $true -VM $Match_VMs.Entity.Name
                    }
                else
                    {
                    Write-Host Affinity $Client_Code $Role_Type VMs: $Match_VMs.Entity.Name -ForegroundColor DarkGreen
                    }
                }
            }
        elseif ($Match_VMs.count -gt $Host_Count)
            {
            if ($Confirmation -eq 'yes')
                {
                $Subject = "VM Rule Set Failed in $Cluster - $Client_Code $Role_Type"
                $Body = "Host Count: $Host_Count`nCluster: $Cluster`nVMs: $($Match_VMs.Entity.Name)"
                Send-MailMessage -To $EmailTo -From $EmailFrom  -Subject $Subject -Body $Body -Credential $SMTPCreds -UseSSL -SmtpServer $SMTPS -Port $SMTP_Port
                }
            else
                {
                Write-Host Error - too many VMs: $Match_VMs.Entity.Name -ForegroundColor Yellow -BackgroundColor DarkRed
                }
            }
        }
    }