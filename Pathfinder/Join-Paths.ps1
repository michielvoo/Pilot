function Join-Paths
{
    [CmdletBinding()]
    [OutputType([string])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Use plural to avoid duplicate name")]
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
