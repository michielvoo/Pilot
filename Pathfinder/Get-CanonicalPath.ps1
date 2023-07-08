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
        if (Test-Path $providerPath)
        {
            $leaf = Split-Path $providerPath -Leaf
            $parent = Split-Path $providerPath -Parent
            if ($parent -eq [string]::Empty) {
                $node = (Get-ChildItem "/" -Filter $leaf -Force).Name
            }
            else {
                $node = (Get-ChildItem $parent -Filter $leaf -Force).Name
            }

            $segments += "$node"
        }
        else
        {
            $leaf = Split-Path $providerPath -Leaf
            $segments += $leaf
        }

        $parent = Split-Path $providerPath -Parent

        if ($parent -eq [string]::Empty) {
            $qualifier = Split-Path $providerPath -Qualifier -ErrorAction SilentlyContinue
            if ($qualifier) {
                $segments += $qualifier
            }
            else {
                $segments += [string]::Empty
            }

            break
        }
        
        $providerPath = $parent
    }

    [array]::Reverse($segments)
    [string]::Join([System.IO.Path]::DirectorySeparatorChar, $segments)
}