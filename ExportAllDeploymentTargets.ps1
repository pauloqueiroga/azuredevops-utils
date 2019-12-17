param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectUri,
    [string]$OutputToFile="deploymenttargets.csv"
)

$credential = Get-Credential
$getDeploymentGroupsUri = "$ProjectUri/_apis/distributedtask/deploymentgroups?api-version=5.0-preview.1"
Write-Debug "URI: $getDeploymentGroupsUri"
$allGroups = Invoke-RestMethod -Method Get -Uri $getDeploymentGroupsUri -Credential $credential
Write-Debug "Groups found: $($allgroups.count)"

foreach ($group in $allGroups.value) {
    Write-Debug "Trying group with ID: $($group.id)"
    $getDetailUri = "$ProjectUri/_apis/distributedtask/deploymentgroups/$($group.id)?api-version=5.0-preview.1"
    Write-Debug "URI: $getDetailUri"
    $detail = Invoke-RestMethod -Method Get -Uri $getDetailUri -Credential $credential
    Write-Debug "Agents found: $($detail.machineCount)"

    foreach ($target in $detail.machines) {
        Write-Output $target.agent.name
        Add-Content -Path $OutputToFile -Value "$($target.agent.name),$($target.agent.version),$($target.agent.osDescription),$($target.agent.enabled),$($target.agent.status)"
    }
}
