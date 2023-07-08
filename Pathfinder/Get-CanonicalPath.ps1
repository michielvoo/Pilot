function Get-CanonicalPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory)]
        [string] $Path
    )

    # Determine provider path
    $provider = $null
    $drive = $null
    $providerPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path, [ref] $provider, [ref] $drive)

    # Guard against unsupported providers
    if ($provider -ne (Get-PSProvider -PSProvider "FileSystem")) {
        $message = "$($MyInvocation.MyCommand.Name) does not support the $provider provider"
        $parameters = @{
            Exception = [System.NotSupportedException]::new($message)
            ErrorId = "PSProviderNotSupported"
            Message = $message
        }
        Write-Error @parameters
    }

    # Get the root-relative provider path
    $index = $drive.Root.Length
    $length = $providerPath.Length - $index
    $rootRelativeProviderPath = $providerPath.Substring($index, $length)

    # Return the drive root when there is no root-relative provider path
    if ($rootRelativeProviderPath -eq ([string]::Empty)) {
        return $drive.Root
    }

    # Split the root-relative provider path on directory separators
    $separator = [System.IO.Path]::DirectorySeparatorChar
    $segments = $rootRelativeProviderPath.Split($separator)

    # Start with the drive root ("C:\" or "D:\" etc., or "/")
    $canonicalPath = $drive.Root

    # Loop over the segments of the root-relative provider path
    for ($i = 0; $i -lt $segments.Length; $i++) {
        $segment = $segments[$i]

        # First segment can be empty if the drive root is "/"
        if ($segment -eq ([string]::Empty)) {
            continue
        }

        # Check if a file with the name of the segment exists in the currently built canonical path
        $exists = Test-Path (Join-Path $canonicalPath $segment)
        if ($exists) {
            # When the file system is case-insensitive, the item will be found even if the case does not match
            $item = Get-ChildItem $canonicalPath -Filter $segment -Force

            # Replace the segment with the case-correct name
            $segment = $item.Name
        }

        $canonicalPath = Join-Path $canonicalPath $segment
    }

    return $canonicalPath
}
