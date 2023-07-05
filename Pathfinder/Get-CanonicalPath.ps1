function Get-CanonicalPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory)]
        [string] $Path
    )

    $providerPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)

    $segments = @()
    while ($true)
    {
        $leaf = Split-Path $providerPath -Leaf
        $parent = Split-Path $providerPath -Parent

        if ($parent -eq [string]::Empty) {
            if (Test-Path $providerPath)
            {
                $root = (Get-Item $providerPath).PSDrive.Root.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
                if ($root)
                {
                    $segments += $root
                }
            }
            
            break
        }

        if (Test-Path $providerPath)
        {
            $segments += (Get-ChildItem $parent -Filter $leaf -Force).Name
        }
        else
        {
            $segments += "$leaf"
        }

        $providerPath = $parent
    }

    [array]::Reverse($segments)
    [string]::Join([System.IO.Path]::DirectorySeparatorChar, $segments)
}