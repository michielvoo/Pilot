. (Join-Path $PSScriptRoot "Write-Error.ps1")
. "$([IO.Path]::DirectorySeparatorChar)" -join @($PSScriptRoot, "..", "Invoke", "Invoke-Git", "Invoke-GitRevList.ps1")
. "$([IO.Path]::DirectorySeparatorChar)" -join @($PSScriptRoot, "..", "Invoke", "Invoke-Git", "Invoke-GitShow.ps1")

# We need to get determine the version of the module to publish
# let $Ref be the current version tag, branch, or given by the CI system
# if ($Ref is a version tag)            <<< v1.2.3 must match tag
#   must be equal to $manifest.version
# else if ($Ref is a branch)            <<< v1.2.3 must be > main's v
#   if ($Ref is main)
#     $sha = preceding commit on main
#   else
#     $sha = current commit on main
#     record the prerelease
#   checkout $sha:manifest
#   $manifest.version should be > $sha:manifest.version
# else
#   $manifest.version should be 1       <<< v must be 1


# .SYNOPSIS
# Gets the version from the module manifest.
# .DESCRIPTION
# The version is checked against the previous version, if any, to ensure it has been incremented.
function Get-Version {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [psmoduleinfo]$ModuleInfo,

        # Current Git branch or version tag
        [Parameter(Mandatory, Position = 1)]
        [string]$Ref,

        # Name of main Git branch
        [Parameter(Mandatory, Position = 2)]
        [string]$Main,

        # Build number
        [Parameter(Mandatory, Position = 3)]
        [string]$Build
    )

    $result = @{}

    # Get the version from the manifest
    [version]$version = $ModuleInfo.Version

    if (-not $version) {
        Write-Error "Version" "Unable to determine version from module manifest"
        return @{ Failed = $true }
    }

    $revListResult = Invoke-GitRevList -Count HEAD
    if ($Ref -match "^v\d+\.\d+\.\d+$")
    {
        # We're on a Git version tag, so only 1 possibility: tag matches version in module manifest
        if ("v$($version.Major).$($version.Minor).$($version.Build)" -ne $Ref)
        {
            Write-Error "Version" "Version in manifest ($version) does not match Git tag ($Ref)"
            return @{ Failed = $true }
        }
    }
    elseif ($revListResult.Stdout[0] -gt 1)
    {
        # We're not on a Git version tag, so 2 possibilities: on the main branch, or on a different branch
        if ($Ref -eq $Main)
        {
            # When on main branch, the previous version can be found one previous commit
            $revision = "HEAD^1"
        }
        else
        {
            # Otherwise we're on a branch, so we need to fetch main from which we've branched off
            # so that we can restore the module manifest from it
            $revision = $Main

            # The refspec is src:dst, so we are getting main
            # This means if main has moved forward in the mean time, we will have to update our version
            Invoke-GitFetch -Depth 1 -Quiet origin "${Main}:$Main"

            # While we are here, we can determine the prerelease based on the branch name
            $topic = $Ref -replace "[^a-zA-Z0-9]",""
            $prerelease = $topic + ("{0:000000}" -f $Build)

            $result.Prerelease = $prerelease
        }

        # Write previous module manifest file from Git history to a temporary file
        $previousManifest = Invoke-GitShow "${Revision}:$(Resolve-Path $manifestPath -Relative)"
        if ($previousManifest.ExitCode -eq 0)
        {
            $tempFile = New-TemporaryFile
            # TODO: copy Git command's stdout to tempFile

            # Parse the previous manifest
            [Version]$current = (Test-ModuleManifest $tempFile).Version

            if (-not ($version -gt $current))
            {
                Write-Error "Version" "Version in manifest does not increment $current"
                return @{ Failed = $true }
            }
        }
    }
    elseif($version -ne [Version] "0.0.1" -and $version -ne [Version] "0.1.0" -and $version -ne [Version] "1.0.0")
    {
        Write-Error "Version" "Version in manifest should be 0.0.1, 0.1.0, or 1.0.0 on initial commit, or fetch depth must be at least 2."
        return @{ Failed = $true }
    }
}
