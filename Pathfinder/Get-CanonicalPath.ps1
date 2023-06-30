function Get-CanonicalPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory)]
        [string]
        $LiteralPath
    )

    $pathIntrinsics = $ExecutionContext.SessionState.Path
    $drive = $null
    $provider = $null
    $path = $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($LiteralPath, [ref]$provider, [ref]$drive)

    $segments = @()
    while ($true)
    {
        $leaf = Split-Path $path -Leaf
        $parent = Split-Path $path -Parent

        if ($parent -eq [string]::Empty) {
            $segments += "$(Split-Path $path -Qualifier)"
            break
        }

        if (Test-Path $path)
        {
            $segments += (Get-ChildItem $parent -Filter $leaf -Force).Name
        }
        else
        {
            $segments += "$leaf"
        }

        $path = $parent
    }

    [array]::Reverse($segments)
    [string]::Join([System.IO.Path]::DirectorySeparatorChar, $segments)
}