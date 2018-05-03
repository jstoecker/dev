<#
.SYNOPSIS
Deletes local user branches that have a deleted remote branch.
#>
param
(
    # If set, does not ask user if branches should be deleted.
    [switch]$Force
)

function Remove-GitBranch([string]$Name, [switch]$Confirm)
{
    $ShouldDelete = $True

    if ($Confirm)
    {
        $ShouldDelete = $False
        $Option = Read-Host "Delete $Name`? [Y] Yes  [N] No  (default is `"N`")"
        if ($Option -and ($Option.ToLower() -eq 'y'))
        {
            $ShouldDelete = $True
        }
    }

    if ($ShouldDelete)
    {
        git branch -D $Name
    }
}

Write-Host "Fetching and pruning stale remote-tracking branches..." -NoNewline
git fetch --prune
Write-Host " done."

Write-Host "Searching for stale local branches..." -NoNewline
$StaleBranches = @(git branch -vv) -match '[0-9a-f]+ \[.*: gone\]'
$StaleBranches = $StaleBranches -replace '\s+(.*) [a-f0-9]+ \[.*', '$1'
Write-Host " done."

if ($StaleBranches.Count -gt 0)
{
    $Option = 'n'
    if ($Force)
    {
        $Option = 'y'
    }
    else
    {
        Write-Host "Stale branches:"
        $StaleBranches | ForEach-Object { "    $_" | Out-Host }
        Write-Host ""

        $HostOption = Read-Host "Delete branches? [Y] Yes to all  [S] Select branches  [N] No / cancel  (default is `"N`")"
        if ($HostOption)
        {
            $Option = $HostOption.ToLower()
        }
    }

    if ($Option -eq 's')
    {
        $StaleBranches | ForEach-Object { Remove-GitBranch -Name $_ -Confirm }
    }
    elseif ($Option -eq 'y')
    {
        $StaleBranches | ForEach-Object { Remove-GitBranch -Name $_ }
    }
}
else
{
    Write-Host "No stale branches to delete."
}