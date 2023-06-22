param (
    [Parameter(Mandatory=$true)]
    [string]$OrganizationUri,
    [string]$OutputToFile="pullrequests.csv",
    [string]$MinDate,
    [string]$MaxDate
)

$credential = Get-Credential
$getPullRequestsUri = "$OrganizationUri/_apis/git/pullrequests?api-version=7.1-preview.1&searchCriteria.status=completed&searchCriteria.queryTimeRangeType=closed&searchCriteria.minTime=$MinDate&searchCriteria.maxTime=$MaxDate"
Write-Debug "URI: $getPullRequestsUri"
$allPrs = Invoke-RestMethod -Method Get -Uri $getPullRequestsUri -Credential $credential
Write-Debug "PRs found: $($allPrs.count)"
New-Item -ItemType File -Path $OutputToFile
Add-Content -Path $OutputToFile -Value "pullRequestId,authorId,authorDescriptor,authorUsername,creationDate,closedDate,repository,project,sourceRefName,targetRefName,mergeStatus,reviewersCount,url,lastMergeCommit"
foreach ($pr in $allPrs.value) {
    Write-Debug "Pull Request ID: $($pr.pullRequestId)"
    Add-Content -Path $OutputToFile -Value "$($pr.pullRequestId),$($pr.createdBy.id),$($pr.createdBy.descriptor),$($pr.createdBy.uniqueName),$($pr.creationDate),$($pr.closedDate),$($pr.repository.name),$($pr.repository.project.name),$($pr.sourceRefName),$($pr.targetRefName),$($pr.mergeStatus),$($pr.reviewers.Count),$($pr.url),$($pr.lastMergeCommit.commitId)"
}