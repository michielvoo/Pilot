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

    Write-Warning "Provider path: $providerPath"

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

    Write-Warning "Roo-relative provider path: $rootRelativeProviderPath"

    # Return the drive root when there is no root-relative provider path
    if ($rootRelativeProviderPath -eq ([string]::Empty)) {
        return $drive.Root
    }

    # Split the root-relative provider path on directory separators
    $separator = [System.IO.Path]::DirectorySeparatorChar
    $segments = $rootRelativeProviderPath.Split($separator)

    Write-Warning "Segments: $segments"

    # Start with the drive root ("C:\" or "D:\" etc., or "/")
    $canonicalPath = $drive.Root

    Write-Warning "Canonical path: $canonicalPath"

    # Loop over the segments of the root-relative provider path
    for ($i = 0; $i -lt $segments.Length; $i++) {
        $segment = $segments[$i]

        # First segment can be empty if the drive root is "/"
        if ($segment -eq ([string]::Empty)) {
            continue
        }

        Write-Warning "Segment: $segment"

        # Check if a file with the name of the segment exists in the currently built canonical path
        if ($canonicalPath -eq $drive.Root) {
            $exists = Test-Path "$canonicalPath$segment"
        }
        else {
            $exists = Test-Path (Join-Path $canonicalPath $segment)
        }

        if ($exists) {
            # When the file system is case-insensitive, the item will be found even if the case does not match
            $item = Get-ChildItem $canonicalPath -Filter $segment -Force

            Write-Warning "Canonical path: $canonicalPath, segment: $segment, item: $($item.Name)"

            # Replace the segment with the case-correct name
            $segment = $item.Name
        }
        else {
            Write-Warning "Did not exist"
        }

        $canonicalPath = Join-Path $canonicalPath $segment
    }

    return $canonicalPath
}
