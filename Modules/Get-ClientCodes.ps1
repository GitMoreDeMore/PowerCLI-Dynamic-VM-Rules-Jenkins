function Get-ClientCodes
    {
    Param([string[]] $Cluster,[string[]] $Server_Options)
    foreach($Client_Code in Get-Tag -Category "Client_Code")
        {
        Add-DRSVMRules $Client_Code.Name $Cluster $Server_Options
        }
    }