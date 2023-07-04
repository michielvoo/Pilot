function Join-Paths
{
    [CmdletBinding()]
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
