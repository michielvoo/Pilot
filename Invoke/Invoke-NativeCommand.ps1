function Invoke-NativeCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $LiteralPath,

        [Parameter(ValueFromRemainingArguments)]
        [string[]] $Arguments
    )

    & $LiteralPath @Arguments
}
