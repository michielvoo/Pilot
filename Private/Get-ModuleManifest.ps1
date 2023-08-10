. (Join-Path $PSScriptRoot "Write-Error.ps1")

# .SYNOPSIS
# Attempts to find the module manifest in the provided location.
# .DESCRIPTION
# Returns a hash table with a boolean Failed key that is set to $true if the manifest file was
# found and valid. The Path key contains the path to the manifest file, and the ModuleInfo
# provides a PSModuleInfo object with the data from the manifest file.
function Get-ModuleManifest {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$LiteralPath,

        [Parameter(Mandatory, Position = 1)]
        [string]$ModuleName
    )

    $manifest = @{
        Path = (Join-Path $LiteralPath "$ModuleName.psd1")
    }

    $parameters = @{
        Path = $manifest.Path
        ErrorAction = "Stop"
    }
    try {
        $manifest.ModuleInfo = Test-ModuleManifest @parameters
    }
    catch {
        $manifest.Failed = $true

        Write-Error "Manifest" $_
    }

    return  $manifest
}