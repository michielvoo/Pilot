. (Join-Path $PSScriptRoot (Join-Path ".." "Invoke-NativeCommand.ps1"))

# The stupid content tracker
function Invoke-Git {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 1)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    Invoke-NativeCommand "git" $Command @Arguments
}