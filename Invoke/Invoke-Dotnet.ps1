. (Join-Path $PSScriptRoot "Invoke-NativeCommand.ps1")

function Invoke-Dotnet {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 1)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    Invoke-NativeCommand "dotnet" $Command @Arguments
}