. (Join-Path $PSScriptRoot "Invoke-Dotnet.ps1")

function Invoke-DotnetTool {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments
    )

    Invoke-Dotnet "tool" $Command @Arguments
}