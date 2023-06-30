function Join-Paths
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]
        $ChildPaths
    )

    $result = $Path 
    foreach ($childPath in $ChildPaths)
    {
        $result = Join-Path $result $childPath
    }

    $result
}