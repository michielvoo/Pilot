function Join-Paths
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Alias("PSPath")]
        [Parameter(Mandatory, Position = 0)]
        [string] $Path,

        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]] $ChildPath
    )

    $result = $Path
    foreach ($value in $ChildPath) {
        $result = Join-Path $result $value
    }

    $result
}
