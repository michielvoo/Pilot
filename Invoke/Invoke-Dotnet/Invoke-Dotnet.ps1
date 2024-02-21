. "$PSScriptRoot/../Invoke-NativeCommand.ps1"

# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet

# .SYNOPSIS
# The generic driver for the .NET CLI.
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