workflow shutdownstartbytagv3
{
        Param(
        [Parameter(Mandatory=$true)]
        [String]
        $TagName,
        [Parameter(Mandatory=$true)]
        [String]
        $TagValue,
        [Parameter(Mandatory=$true)]
        [Boolean]
        $Shutdown,
		[Parameter(Mandatory=$true)]
        [String]
        $AzureSubscriptionID
        )
 
# connect to Azure, suppress output
try {
    $null = Connect-AzAccount -Identity
}
catch {
    $ErrorMessage = "Error connecting to Azure: " + $_.Exception.message
    Write-Error $ErrorMessage
    throw $ErrorMessage
    exit
}

# select Azure subscription by ID if specified, suppress output
if ($AzureSubscriptionID) {
    try {
        $null = Set-AzContext -Subscription $AzureSubscriptionID
    }
    catch {
        $ErrorMessage = "Error selecting Azure Subscription ($AzureSubscriptionID): " + $_.Exception.message
        Write-Error $ErrorMessage
        throw $ErrorMessage
        exit
    }
}
         
  
    $vms = Get-AzResource -TagName $TagName -TagValue $TagValue | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}
     
    Foreach -Parallel ($vm in $vms){
        
        if($Shutdown){
            Write-Output "Stopping $($vm.Name)";        
            Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force;
        }
        else{
            Write-Output "Starting $($vm.Name)";        
            Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }
    }
}
